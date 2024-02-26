codeunit 50300 PrintNode
{
    var
        Base64: Codeunit "Base64 Convert";
        Authlbl: Label 'Basic %1:%2';

    procedure GetPrinters(ApiKey: Text; var whoamiid: Text) Result: Dictionary of [Text, Text]
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpResponseMessage: HttpResponseMessage;
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        Url: Label 'https://api.printnode.com/printers';
        Response: Text;
        PrinterId: Text;
        PrinterName: Text;
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders;
        HttpHeaders.Add('Authorization', StrSubstNo(Authlbl, Base64.ToBase64(ApiKey), ''));
        HttpClient.Get(Url, HttpResponseMessage);
        HttpResponseMessage.Content.ReadAs(Response);
        if HttpResponseMessage.IsSuccessStatusCode then begin
            JArray.ReadFrom(Response);
            foreach JToken in jArray do begin
                JObject := JToken.AsObject();
                if JObject.Get('name', JToken) then begin
                    PrinterName := JToken.AsValue().AsText();
                    if JObject.Get('id', JToken) then begin
                        PrinterId := JToken.AsValue().AsText();
                        Result.Add(PrinterId, PrinterName);
                    end;
                end;
            end;
            WhoAmI(whoamiid, ApiKey);
        end else
            Error(Response);
    end;

    local procedure WhoAmI(var whoamiid: Text; ApiKey: Text)
    var
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        HttpHeaders: HttpHeaders;
        JsonResponse: JsonObject;
        JToken: JsonToken;
        Response: Text;
        Url: Label 'https://api.printnode.com/whoami';
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', StrSubstNo(Authlbl, Base64.ToBase64(ApiKey), ''));
        HttpClient.Get(Url, HttpResponse);
        HttpResponse.Content.ReadAs(Response);
        if HttpResponse.IsSuccessStatusCode then begin
            JsonResponse.ReadFrom(Response);
            if JsonResponse.Get('id', JToken) then
                whoamiid := JToken.AsValue().AsText();
        end else
            Error(Response);
    end;
}
