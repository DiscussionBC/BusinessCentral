page 50450 "Sales Order Status"
{
    ApplicationArea = All;
    Caption = 'Estado pedidos de venta';
    PageType = List;
    SourceTable = "Sales Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                }
                field("Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
                {
                }
                field("Completely Shipped"; Rec."Completely Shipped")
                {
                }
                field(SatusColor; SatusColor)
                {
                    Caption = 'Estado';
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
                Caption = '🚛';
                Image = none;
                ToolTip = 'Enviar pedido';

                trigger OnAction()
                begin
                    Message('Enviar');
                end;
            }
        }
        area(Promoted)
        {
            actionref(aa1; a1) { }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Completely Shipped" then
            SatusColor := '🟩'
        else
            SatusColor := '🟥';
    end;

    var
        SatusColor: Text;

}
