page 60801 OAuth2Dialog
{
    PageType = Card;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            usercontrol(OAuthIntegration; "OAuth 2.0 Integration")
            {
                ApplicationArea = All;

                trigger AuthorizationCodeRetrieved(AuthCode: Text; ReturnState: Text);
                var
                    Error001Lbl: Label 'Estados no válidos.';
                begin
                    if State <> ReturnState then
                        Error(Error001Lbl);
                    AuthorizationCode := AuthCode;
                    CurrPage.Close();
                end;

                trigger ControlAddInReady();
                begin
                    CurrPage.OAuthIntegration.StartAuthorization(OAuthRequestUrl);
                end;
            }
        }
    }

    procedure SetOAuth2Properties(AuthRequestUrl: Text; InitialState: Text)
    begin
        OAuthRequestUrl := AuthRequestUrl;
        State := InitialState;
    end;

    procedure GetAuthCode(): Text
    begin
        exit(AuthorizationCode);
    end;

    var
        AuthorizationCode: Text;
        OAuthRequestUrl: Text;
        State: Text;
}