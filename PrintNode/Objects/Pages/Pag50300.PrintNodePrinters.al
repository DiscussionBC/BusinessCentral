page 50300 "PrintNode Printers"
{
    ApplicationArea = All;
    Caption = 'PrintNode Printers';
    PageType = List;
    SourceTable = "Integer";
    UsageCategory = Tasks;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(PrinterId; PrinterId)
                { }
                field(PrinterName; PrinterName)
                { }
                field(Printermail; Printermail)
                { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(a1)
            {
                Caption = 'Añadir todas las impresoras';
                Image = Print;

                trigger OnAction()
                begin
                    AddAllPrinters();
                end;
            }
        }
        area(Promoted)
        {
            actionref(aa1; a1) { }
        }
    }

    trigger OnOpenPage()
    var
        PrintNode: Codeunit PrintNode;
    begin
        Printers := PrintNode.GetPrinters('xxxxxxxxxxxxxxxxxxxxx', WhoAimI);
        PrinterList := Printers.Keys;
        Rec.SetRange(Number, 1, Printers.Count);
        CurrPage.Update(false);
    end;

    var
        Printers: Dictionary of [Text, Text];
        PrinterList: list of [Text];
        PrinterId: Text;
        PrinterName: Text;
        Printermail: Text;
        WhoAimI: Text;
        Mail: Label '%1.%2@lon1.printnode.com';

    trigger OnAfterGetRecord()
    begin
        PrinterList.Get(Rec.Number, PrinterId);
        Printers.Get(PrinterId, PrinterName);
        Printermail := StrSubstNo(Mail, PrinterId, WhoAimI);
    end;

    local procedure AddAllPrinters()
    var
        EmailPrinterSettings: Record "Email Printer Settings";
        Id: Text;
        Name: Text;
        Msg001: Label 'Proceso finalizado';
    begin
        foreach Id in PrinterList do begin
            Printers.Get(Id, Name);
            EmailPrinterSettings.Reset();
            EmailPrinterSettings.SetRange("Email Address", StrSubstNo(Mail, Id, WhoAimI));
            if not EmailPrinterSettings.FindFirst() then begin
                EmailPrinterSettings.Init();
                EmailPrinterSettings.ID := Name;
                EmailPrinterSettings."Email Address" := StrSubstNo(Mail, Id, WhoAimI);
                EmailPrinterSettings.Description := Name;
                EmailPrinterSettings."Email Subject" := '';
                EmailPrinterSettings.Validate("Paper Size", EmailPrinterSettings."Paper Size"::A4);
                EmailPrinterSettings.Insert();
            end;
        end;
        Message(Msg001);
    end;
}
