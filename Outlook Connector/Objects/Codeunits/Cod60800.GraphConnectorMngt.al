codeunit 60800 GraphConnectorMngt
{
    var
        Calendars: Record Calendars;
        GraphSetup: Record GraphSetup;

    procedure CheckConfig()
    var
        Error001Lbl: Label 'No existe configuración, por favor, cree una antes de continuar.';
    begin
        if not GraphSetup.Get() then
            Error(Error001Lbl);

        GraphSetup.TestField("Authorization URL");
        GraphSetup.TestField("Token URL");
        GraphSetup.TestField("Client ID");
        GraphSetup.TestField("Redirect URL");
        GraphSetup.TestField(Scope);
    end;

    #region Auth+Token
    procedure GetAuthorizationCode() AuthorizationCode: Text
    var
        DotNetUriBuilder: Codeunit Uri;
        OAuth2Dialog: Page OAuth2Dialog;
        Error001Lbl: Label 'El código de autorización no es válido.';
        AuthURL: Text;
        State: Text;
    begin
        State := Format(CreateGuid(), 0, 4);

        AuthURL := GraphSetup."Authorization URL" + '?' +
                    'client_id=' + DotNetUriBuilder.EscapeDataString(GraphSetup."Client ID") +
                    '&redirect_uri=' + DotNetUriBuilder.EscapeDataString(GraphSetup."Redirect URL") +
                    '&state=' + DotNetUriBuilder.EscapeDataString(State) +
                    '&scope=' + GraphSetup.Scope +
                    '&response_type=code';

        OAuth2Dialog.SetOAuth2Properties(AuthURL, State);
        OAuth2Dialog.RunModal();

        AuthorizationCode := OAuth2Dialog.GetAuthCode();

        if AuthorizationCode = '' then
            Error(Error001Lbl);
    end;

    procedure GetAccessToken(AuthCode: Text)
    var
        DotNetUriBuilder: Codeunit Uri;
        Success: Boolean;
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        JAccessToken: JsonObject;
        JToken: JsonToken;
        OStream: OutStream;
        ContentText: Text;
        Property: Text;
        ResponseText: Text;
        Secret: Text;
    begin
        CheckConfig();
        IsolatedStorage.Get('Secret', Secret);
        ContentText := 'grant_type=authorization_code' +
                                '&code=' + AuthCode +
                                '&redirect_uri=' + DotNetUriBuilder.EscapeDataString(GraphSetup."Redirect URL") +
                                '&client_id=' + GraphSetup."Client ID" +
                                '&client_secret=' + Secret;

        Content.WriteFrom(ContentText);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        Request.Method := 'POST';
        Request.SetRequestUri(GraphSetup."Token URL");
        Request.Content(Content);

        Client.Send(Request, Response);
        Response.Content.ReadAs(ResponseText);
        if Response.IsSuccessStatusCode() then
            Success := JAccessToken.ReadFrom(ResponseText)
        else
            Error(ResponseText);

        if Success then begin
            foreach Property in JAccessToken.Keys() do begin
                JAccessToken.Get(Property, JToken);
                case Property of
                    'token_type',
                    'scope':
                        ;
                    'expires_in', 'expires_on':
                        begin
                            GraphSetup."Expires In" := JToken.AsValue().AsInteger();
                            GraphSetup."Authorization Time" := CurrentDateTime;
                        end;
                    'ext_expires_in':
                        GraphSetup."RefTkn Expires In" := JToken.AsValue().AsInteger();
                    'access_token':
                        begin
                            GraphSetup."Access Token".CreateOutStream(OStream, TextEncoding::UTF8);
                            OStream.WriteText(JToken.AsValue().AsText());
                        end;
                    'refresh_token':
                        begin
                            GraphSetup."Refresh Token".CreateOutStream(OStream, TextEncoding::UTF8);
                            OStream.WriteText(JToken.AsValue().AsText());
                        end;
                end;
            end;
            GraphSetup.Modify();
        end;
    end;

    procedure GetOrUpdateToken() Token: Text
    var
        NeedToken: Boolean;
        ElapsedSecs: Integer;
        AuthCode: Text;
    begin
        CheckConfig();        
        if (GraphSetup."Authorization Time" <> 0DT) then begin
            ElapsedSecs := Round((CurrentDateTime() - GraphSetup."Authorization Time") / 1000, 1, '>');
            if ElapsedSecs >= GraphSetup."Expires In" then
                if not RefreshAccessToken() then
                    NeedToken := true;
        end else
            NeedToken := true;
        if NeedToken then begin
            AuthCode := GetAuthorizationCode();
            GetAccessToken(AuthCode);
        end;
        Token := GraphSetup.AccessTokenToText();
    end;

    procedure RefreshAccessToken(): Boolean
    var
        DotNetUriBuilder: Codeunit Uri;
        Success: Boolean;
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        JAccessToken: JsonObject;
        JToken: JsonToken;
        OStream: OutStream;
        ContentText: Text;
        Property: Text;
        RefreshToken: Text;
        ResponseText: Text;
        Secret: Text;
    begin
        CheckConfig();
        IsolatedStorage.Get('Secret', Secret);
        RefreshToken := RefreshTokenToText();
        if RefreshToken = '' then
            exit;

        GraphSetup."Authorization Time" := CurrentDateTime();

        ContentText := 'grant_type=refresh_token' +
            '&refresh_token=' + DotNetUriBuilder.EscapeDataString(RefreshToken) +
            '&redirect_uri=' + DotNetUriBuilder.EscapeDataString(GraphSetup."Redirect URL") +
            '&client_id=' + DotNetUriBuilder.EscapeDataString(GraphSetup."Client ID") +
            '&client_secret=' + DotNetUriBuilder.EscapeDataString(Secret);
        Content.WriteFrom(ContentText);

        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        Request.Method := 'POST';
        Request.SetRequestUri(GraphSetup."Token URL");
        Request.Content(Content);

        if Client.Send(Request, Response) then
            if Response.IsSuccessStatusCode() then
                if Response.Content.ReadAs(ResponseText) then
                    Success := JAccessToken.ReadFrom(ResponseText);

        if Success then begin
            foreach Property in JAccessToken.Keys() do begin
                JAccessToken.Get(Property, JToken);
                case Property of
                    'token_type',
                    'scope':
                        ;
                    'expires_in':
                        GraphSetup."Expires In" := JToken.AsValue().AsInteger();
                    'ext_expires_in':
                        GraphSetup."RefTkn Expires In" := JToken.AsValue().AsInteger();
                    'access_token':
                        begin
                            GraphSetup."Access Token".CreateOutStream(OStream, TextEncoding::UTF8);
                            OStream.WriteText(JToken.AsValue().AsText());
                        end;
                    'refresh_token':
                        begin
                            GraphSetup."Refresh Token".CreateOutStream(OStream, TextEncoding::UTF8);
                            OStream.WriteText(JToken.AsValue().AsText());
                        end;
                end;
            end;
            GraphSetup.Modify();
            Commit();
        end;
        exit(Success);
    end;

    procedure RefreshTokenToText(): Text
    var
        IStream: InStream;
        Line: Text;
        Buffer: TextBuilder;
    begin
        GraphSetup.CalcFields("Refresh Token");
        if GraphSetup."Refresh Token".HasValue then begin
            GraphSetup."Refresh Token".CreateInStream(IStream, TextEncoding::UTF8);
            while not IStream.EOS do begin
                IStream.ReadText(Line, 1024);
                Buffer.Append(Line);
            end;
        end;
        exit(Buffer.ToText())
    end;

    #endregion Auth+Token

    #region WebService

    local procedure GetEntity(Url: Text) Response: Text
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        Token: Text;
    begin
        Token := GetOrUpdateToken();
        Headers := Client.DefaultRequestHeaders();
        Headers.Add('Authorization', StrSubstNo('Bearer %1', Token));
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method := 'GET';

        if Client.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode() then
                Response := ResponseText
            else
                Error(ResponseText);
        end;
    end;

    procedure GetAllCalendars()
    var
        CalendarArray: JsonArray;
        CalendarObject: JsonObject;
        JResponse: JsonObject;
        CalendarToken: JsonToken;
        JToken: JsonToken;
        Url: Label 'https://graph.microsoft.com/v1.0/me/calendars?$select=name,hexColor,isDefaultCalendar';
        ResponseText: Text;
    begin
        ResponseText := GetEntity(Url);
        Calendars.SetRange(UserGuid, UserSecurityId());
        Calendars.DeleteAll();
        JResponse.ReadFrom(ResponseText);
        if JResponse.Get('value', JToken) then begin
            CalendarArray := JToken.AsArray();
            foreach JToken in CalendarArray do begin
                CalendarObject := JToken.AsObject();
                if CalendarObject.Get('id', CalendarToken) then
                    if not Calendars.Get(CalendarToken.AsValue().AsText()) then begin
                        Calendars.Init();
                        Calendars.Id := CopyStr(CalendarToken.AsValue().AsText(), 1, MaxStrLen(Calendars.Id));
                        if CalendarObject.Get('name', CalendarToken) then
                            Calendars.Name := CopyStr(CalendarToken.AsValue().AsText(), 1, MaxStrLen(Calendars.Name));
                        if CalendarObject.Get('hexColor', CalendarToken) then
                            Calendars.Colour := CopyStr(CalendarToken.AsValue().AsText(), 1, MaxStrLen(Calendars.Colour));
                        if CalendarObject.Get('isDefaultCalendar', CalendarToken) then
                            Calendars.IsDefault := CalendarToken.AsValue().AsBoolean();
                        Calendars.UserGuid := UserSecurityId();
                        Calendars.Insert();
                    end;
            end;
        end;
    end;

    procedure GetCalendarEvents(CalendarId: Text) JResponse: JsonArray;
    var
        AllDay: Boolean;
        EndDateTime: DateTime;
        StartDateTime: DateTime;
        JArray: JsonArray;
        DateTimeObject: JsonObject;
        JObject: JsonObject;
        EventToken: JsonToken;
        JToken: JsonToken;
        Url: Label 'https://graph.microsoft.com/v1.0/me/calendars/%1/events?$select=subject,bodyPreview,start,end,isAllDay';
        id: Text;
        ResponseText: Text;
        subject: Text;
    begin
        ResponseText := GetEntity(StrSubstNo(Url, CalendarId));
        Calendars.SetRange(Id, CalendarId);
        if Calendars.FindFirst() then begin
            JObject.ReadFrom(ResponseText);
            if JObject.Get('value', JToken) then begin
                JArray := JToken.AsArray();
                foreach JToken in JArray do begin
                    JObject := JToken.AsObject();
                    if JObject.Get('id', EventToken) then begin
                        id := EventToken.AsValue().AsText();
                        if JObject.Get('subject', EventToken) then
                            subject := EventToken.AsValue().AsText();
                        if JObject.Get('bodyPreview', EventToken) then
                            if EventToken.AsValue().AsText() <> '' then
                                subject := EventToken.AsValue().AsText();
                        if JObject.Get('isAllDay', EventToken) then
                            AllDay := EventToken.AsValue().AsBoolean();
                        if JObject.Get('start', EventToken) then begin
                            DateTimeObject := EventToken.AsObject();
                            if DateTimeObject.Get('dateTime', EventToken) then
                                StartDateTime := EventToken.AsValue().AsDateTime();
                        end;
                        if (JObject.Get('end', EventToken)) then begin
                            DateTimeObject := EventToken.AsObject();
                            if DateTimeObject.Get('dateTime', EventToken) then
                                EndDateTime := EventToken.AsValue().AsDateTime();
                        end;
                        if AllDay then begin
                            StartDateTime -= 3600000;
                            EndDateTime -= 3600000;
                        end;

                        JResponse.Add(AddEvent(id, subject, StartDateTime, EndDateTime, Calendars.Colour, '#000000', '#000000'));
                    end;
                end;
            end;
        end;
    end;

    procedure NewEvent(Calendar: Text; Subject: Text; BodyContent: Text; StartEvent: DateTime; EndEvent: DateTime; AllDay: Boolean): Boolean
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        Url: Label 'https://graph.microsoft.com/v1.0/me/calendars/%1/events';
        ContentTxt: Text;
        ResponseText: Text;
        Token: Text;
    begin
        Token := GetOrUpdateToken();
        Headers := Client.DefaultRequestHeaders();
        Headers.Add('Authorization', StrSubstNo('Bearer %1', Token));
        JObject := CreateBodyForRequest(Subject, BodyContent, StartEvent, EndEvent, AllDay);
        JObject.WriteTo(ContentTxt);
        Content.WriteFrom(ContentTxt);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        RequestMessage.SetRequestUri(StrSubstNo(Url, Calendar));
        RequestMessage.Method := 'POST';
        RequestMessage.Content(Content);
        if Client.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode() then
                exit(true)
            else
                exit(false);
        end;
    end;

    procedure ModifyEvent(id: Text; StartEvent: DateTime; EndEvent: DateTime; AllDay: Boolean): Boolean
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        Url: Label 'https://graph.microsoft.com/v1.0/me/events/%1';
        ContentTxt: Text;
        ResponseText: Text;
        Token: Text;
    begin
        Token := GetOrUpdateToken();
        Headers := Client.DefaultRequestHeaders();
        Headers.Add('Authorization', StrSubstNo('Bearer %1', Token));
        JObject := CreateBodyForRequest(StartEvent, EndEvent, AllDay);
        JObject.WriteTo(ContentTxt);
        Content.WriteFrom(ContentTxt);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        RequestMessage.SetRequestUri(StrSubstNo(Url, id));
        RequestMessage.Method := 'PATCH';
        RequestMessage.Content(Content);
        if Client.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode() then
                exit(true)
            else
                exit(false);
        end;
    end;

    procedure DeleteEvent(id: Text): Boolean
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Url: Label 'https://graph.microsoft.com/v1.0/me/events/%1';
        ResponseText: Text;
        Token: Text;
    begin
        Token := GetOrUpdateToken();
        Headers := Client.DefaultRequestHeaders();
        Headers.Add('Authorization', StrSubstNo('Bearer %1', Token));

        RequestMessage.SetRequestUri(StrSubstNo(Url, id));
        RequestMessage.Method := 'DELETE';
        RequestMessage.Content(Content);
        if Client.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode() then
                exit(true)
            else
                exit(false);
        end;
    end;

    #endregion WebService

    #region Utils    
    local procedure AddEvent(id: Text; Title: Text; StartEvent: DateTime; EndEvent: DateTime; color: Text; BorderColor: Text; TextColor: Text): JsonObject
    var
        MyEvent: JsonObject;
        TxtBuilder: TextBuilder;
    begin
        MyEvent.Add('id', id);
        MyEvent.Add('title', Title);
        if EndEvent <> 0DT then begin
            MyEvent.Add('start', StartEvent);
            TxtBuilder.AppendLine(Format(DT2Date(StartEvent)) + ' ' + Format(DT2Time(StartEvent)))
        end else begin
            MyEvent.Add('start', DT2Date(StartEvent));
            TxtBuilder.AppendLine(Format(DT2Date(StartEvent)) + ' todo el día');
        end;
        if EndEvent <> 0DT then begin
            MyEvent.Add('end', EndEvent);
            TxtBuilder.AppendLine(Format(DT2Date(EndEvent)) + ' ' + Format(DT2Time(EndEvent)))
        end;
        TxtBuilder.AppendLine('   ');
        TxtBuilder.AppendLine(Title);
        MyEvent.Add('description', TxtBuilder.ToText());
        MyEvent.Add('color', color);
        MyEvent.Add('borderColor', BorderColor);
        MyEvent.Add('textColor', TextColor);
        MyEvent.Add('display', 'block');
        MyEvent.Add('bcendevent', EndEvent);
        exit(MyEvent);
    end;

    local procedure CreateBodyForRequest(StartEvent: DateTime; EndEvent: DateTime; AllDay: Boolean) Response: JsonObject
    var
        Type: Option "New","Modify";
    begin
        Response := CreateBodyRequest('', '', StartEvent, EndEvent, AllDay, Type::Modify);
    end;

    local procedure CreateBodyForRequest(Subject: Text; BodyContent: Text; StartEvent: DateTime; EndEvent: DateTime; AllDay: Boolean) Response: JsonObject
    var
        Type: Option "New","Modify";
    begin
        Response := CreateBodyRequest(Subject, BodyContent, StartEvent, EndEvent, AllDay, Type::New);
    end;

    local procedure CreateBodyRequest(Subject: Text; BodyContent: Text; StartEvent: DateTime; EndEvent: DateTime; AllDay: Boolean; Type: Option "New","Modify") Response: JsonObject
    var
        BodyObject: JsonObject;
        EndObject: JsonObject;
        StartObject: JsonObject;
    begin
        if Type = type::New then begin
            Response.Add('subject', Subject);
            BodyObject.Add('contentType', 'HTML');
            BodyObject.Add('content', BodyContent);
            Response.Add('body', BodyObject);
        end;

        Response.Add('isAllDay', AllDay);
        if AllDay then begin
            StartEvent += 3600000;
            EndEvent := CreateDateTime(CalcDate('<1D>', DT2Date(StartEvent)), 0T) + 3600000;
        end;
        StartObject.Add('dateTime', StartEvent);
        StartObject.Add('timeZone', 'UTC');
        Response.Add('start', StartObject);
        EndObject.Add('dateTime', EndEvent);
        EndObject.Add('timeZone', 'UTC');
        Response.Add('end', EndObject);
    end;
    #endregion Utils    
}
