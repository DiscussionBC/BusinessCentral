page 50104 "Excel Importt Test"
{
    ApplicationArea = All;
    Caption = 'Excel Import Test';
    PageType = List;
    SourceTable = "Excel Buffer";
    SourceTableTemporary = true;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Row No."; Rec."Row No.")
                {
                }
                field(xlRowID; Rec.xlRowID)
                {
                }
                field("Column No."; Rec."Column No.")
                {
                }
                field(xlColID; Rec.xlColID)
                {
                }
                field("Cell Value as Text"; Rec."Cell Value as Text")
                {
                }
                field(Comment; Rec.Comment)
                {
                }
                field(Formula; Rec.Formula)
                {
                }
                field(Bold; Rec.Bold)
                {
                }
                field(Italic; Rec.Italic)
                {
                }
                field(Underline; Rec.Underline)
                {
                }
                field(NumberFormat; Rec.NumberFormat)
                {
                }
                field(Formula2; Rec.Formula2)
                {
                }
                field(Formula3; Rec.Formula3)
                {
                }
                field(Formula4; Rec.Formula4)
                {
                }
                field("Cell Type"; Rec."Cell Type")
                {
                }
                field(MyType; Rec.MyType)
                {
                }
                field("Double Underline"; Rec."Double Underline")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(a1)
            {
                Caption = 'Importar Excel';
                Image = Excel;

                trigger OnAction()
                var
                    Istr: InStream;
                    FromFile: Text;
                    Sheet: Text;
                    Error001: Label 'No se ha seleccionado un fichero';
                begin
                    Rec.Reset();
                    Rec.DeleteAll();
                    if UploadIntoStream('Fichero a importar', '', '', FromFile, Istr) then begin
                        Sheet := Rec.SelectSheetsNameStream(Istr);
                        Rec.OpenBookStream(Istr, Sheet);
                        REc.ReadSheet();
                    end else
                        Error(Error001);
                end;
            }
        }
        area(Promoted)
        {
            actionref(aa1; a1) { }
        }
    }
}
