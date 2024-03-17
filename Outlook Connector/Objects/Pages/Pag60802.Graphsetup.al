page 60802 "Graph setup"
{
    ApplicationArea = All;
    Caption = 'Configuración conector Outlook';
    PageType = Card;
    SourceTable = GraphSetup;
    UsageCategory = Tasks;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Client ID"; Rec."Client ID")
                {
                }
                field("Client Secret"; Rec."Client Secret")
                {
                }
                field("Redirect URL"; Rec."Redirect URL")
                {
                }
                field(Scope; Rec.Scope)
                {
                }
                field("Authorization URL"; Rec."Authorization URL")
                {
                }
                field("Token URL"; Rec."Token URL")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
