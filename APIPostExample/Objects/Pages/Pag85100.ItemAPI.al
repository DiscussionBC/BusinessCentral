page 85100 MyItemAPI
{
    APIGroup = 'apiGroup';
    APIPublisher = 'Publisher';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'itemAPI';
    DelayedInsert = true;
    EntityName = 'myItem';
    EntitySetName = 'myItems';
    PageType = API;
    SourceTable = APIPostExample;
    ODataKeyFields = "No.";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(no; Rec."No.")
                {
                }
                field(fechaInicio; fechaInicio)
                { }
                field(fechaFinal; fechaFinal)
                { }
                field(dtoDesde; dtoDesde)
                { }
                field(dtoHasta; dtoHasta)
                { }
                field(resultadoOperacion1; resultadoOperacion1)
                { }
                field(resultadoOperacion2; resultadoOperacion2)
                { }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        dateFrom: Date;
        dateTo: Date;
        Msg001: Label 'Tarifas desactivadas';
    begin
        resultadoOperacion1 := false; //por si recibieramos valor en la llamada
        resultadoOperacion2 := '';    //por si recibieramos valor en la llamada
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SetRange("No.", Rec."No.");
        Evaluate(dateFrom, fechaInicio);
        Evaluate(dateTo, fechaFinal);
        SalesInvoiceLine.SetRange("Posting Date", dateFrom, dateTo);
        SalesInvoiceLine.SetRange("Line Discount %", dtoDesde, dtoHasta);
        if SalesInvoiceLine.FindFirst() then begin
            resultadoOperacion1 := true;
            PriceListLine.SetRange(Status, PriceListLine.Status::Active);
            PriceListLine.SetRange("Product No.", Rec."No.");
            PriceListLine.SetLoadFields("Price List Code");
            if PriceListLine.FindSet() then
                repeat
                    PriceListHeader.Get(PriceListLine."Price List Code");
                    PriceListHeader.Status := PriceListHeader.Status::Inactive;
                    PriceListHeader.Modify();
                    resultadoOperacion2 := Msg001;
                until PriceListLine.Next() = 0;
        end;
    end;

    var
        fechaInicio: Text;
        fechaFinal: Text;
        dtoDesde: Decimal;
        dtoHasta: Decimal;
        resultadoOperacion1: Boolean;
        resultadoOperacion2: Text;
}
