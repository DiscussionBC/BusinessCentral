table 60800 GraphSetup
{
    Caption = 'Graph Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Client ID"; Text[250])
        {
            Caption = 'Id Cliente';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Client Secret"; Text[250])
        {
            Caption = 'Secreto';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                IsolatedStorage.Set('Secret', "Client Secret");
                "Client Secret" := '';
            end;
        }
        field(4; "Redirect URL"; Text[250])
        {
            Caption = 'URL redirección';
        }
        field(5; Scope; Text[250])
        {
            Caption = 'Ámbito';
        }
        field(6; "Authorization URL"; Text[250])
        {
            Caption = 'URL de autorización';
        }
        field(7; "Token URL"; Text[250])
        {
            Caption = 'URL de token';
        }
        field(8; "Access Token"; Blob)
        {
            Caption = 'Access Token';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Refresh Token"; Blob)
        {
            Caption = 'Refresh Token';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Authorization Time"; DateTime)
        {
            Caption = 'Authorization Time';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "Expires In"; Integer)
        {
            Caption = 'Expires In';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "RefTkn Expires In"; Integer)
        {
            Caption = 'Ext. Expires In';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure AccessTokenToText(): Text
    var
        IStream: InStream;
        Line: Text;
        TxtBuilder: TextBuilder;
    begin
        Rec.CalcFields("Access Token");
        if Rec."Access Token".HasValue then begin
            Rec."Access Token".CreateInStream(IStream, TextEncoding::UTF8);
            while not IStream.EOS do begin
                IStream.ReadText(Line, 1024);
                TxtBuilder.Append(Line);
            end;
        end;
        exit(TxtBuilder.ToText())
    end;
}
