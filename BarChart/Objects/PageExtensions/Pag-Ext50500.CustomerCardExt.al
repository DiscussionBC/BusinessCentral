pageextension 50500 CustomerCardExt extends "Customer Card"
{
    layout
    {
        addfirst(content)
        {
            group(ShippingsVsReturns)
            {
                Caption = 'Envíos vs devoluciones';
                usercontrol(BusinessChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
                {
                    ApplicationArea = Invoicing, Basic, Suite;

                    trigger AddInReady()
                    begin
                        InitChart();
                    end;

                    trigger DataPointClicked(point: JsonObject)
                    begin
                        ChartPointClicked(point);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        InitChart();
    end;

    var
        BusinessChartBuffer: Record "Business Chart Buffer" temporary;
        Last12Months: Dictionary of [Text, Dictionary of [Date, Date]];
        ActualMonth: Dictionary of [Date, Date];

    #region InitChart

    local procedure InitChart()
    var
        MonthList: List of [Text];
        StartDate: Date;
        EndDate: Date;
        Month: Text;
        I: Integer;
    begin
        BusinessChartBuffer.Initialize();
        BusinessChartBuffer.AddMeasure('Envíos', 1, BusinessChartBuffer."Data Type"::Integer, BusinessChartBuffer."Chart Type"::Column.AsInteger()); //medida 1
        BusinessChartBuffer.AddMeasure('Devoluciones', 2, BusinessChartBuffer."Data Type"::Integer, BusinessChartBuffer."Chart Type"::Column.AsInteger()); //medida 2
        BusinessChartBuffer.SetXAxis('Mes', BusinessChartBuffer."Data Type"::String);

        Last12Months := GetLast12Months();
        MonthList := Last12Months.Keys;
        foreach Month in MonthList do begin
            BusinessChartBuffer.AddColumn(Month);
            Last12Months.Get(Month, ActualMonth);
            ActualMonth.Keys.Get(1, StartDate);
            ActualMonth.Values.Get(1, EndDate);
            BusinessChartBuffer.SetValueByIndex(0, I, GetMovs(Enum::"Item Ledger Document Type"::"Sales Shipment", StartDate, EndDate));
            BusinessChartBuffer.SetValueByIndex(1, I, GetMovs(Enum::"Item Ledger Document Type"::"Sales Return Receipt", StartDate, EndDate));
            I += 1;
        end;
        BusinessChartBuffer.Update(CurrPage.BusinessChart);
    end;

    local procedure GetLast12Months() Response: Dictionary of [Text, Dictionary of [Date, Date]]
    var
        ReferenceDate: Date;
        Dates: Dictionary of [Date, Date];
        MonthName: Text;
        I: Integer;
    begin
        ReferenceDate := CalcDate('<-1Y>', Today);
        for I := 1 to 12 do begin
            Clear(Dates);
            ReferenceDate := CalcDate('<1M>', ReferenceDate);
            Dates.Add(CalcDate('<-CM>', ReferenceDate), CalcDate('<CM>', ReferenceDate));
            MonthName := Format(ReferenceDate, 0, '<Month Text>') + '-' + Format(Date2DMY(ReferenceDate, 3));
            Response.Add(MonthName, Dates);
        end;
    end;

    local procedure GetMovs(MovType: Enum "Item Ledger Document Type"; StartDate: Date; EndDate: Date) Result: Integer
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        DocumentNo: Code[20];
    begin
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Document No.");
        ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Customer);
        ItemLedgerEntry.SetRange("Document Type", MovType);
        ItemLedgerEntry.SetRange("Source No.", Rec."No.");
        ItemLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
        ItemLedgerEntry.SetLoadFields("Document No.");
        if ItemLedgerEntry.FindSet() then
            repeat
                if DocumentNo <> ItemLedgerEntry."Document No." then begin
                    DocumentNo := ItemLedgerEntry."Document No.";
                    Result += 1;
                end;
            until ItemLedgerEntry.Next() = 0;
    end;
    #endregion InitChart

    #region UserClickOnChart
    local procedure ChartPointClicked(point: JsonObject)
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        JArray: JsonArray;
        JToken: JsonToken;
        Type: Option Shippings,Returns;
        StartDate: Date;
        EndDate: Date;
    begin
        if point.Get('Measures', JToken) then begin
            JArray := JToken.AsArray();
            JArray.Get(0, JToken);
            if JToken.AsValue().AsText() = 'Envíos' then
                Type := Type::Shippings
            else
                Type := type::Returns;
            if point.Get('XValueString', JToken) then begin
                Last12Months.Get(JToken.AsValue().AsText(), ActualMonth);
                ActualMonth.Keys.Get(1, StartDate);
                ActualMonth.Values.Get(1, EndDate);
                if Type = Type::Shippings then begin
                    SalesShipmentHeader.SetRange("Sell-to Customer No.", Rec."No.");
                    SalesShipmentHeader.SetRange("Posting Date", StartDate, EndDate);
                    Page.Run(Page::"Posted Sales Shipments", SalesShipmentHeader);
                end else begin
                    ReturnReceiptHeader.SetRange("Sell-to Customer No.", Rec."No.");
                    ReturnReceiptHeader.SetRange("Posting Date", StartDate, EndDate);
                    Page.Run(Page::"Posted Return Receipts", ReturnReceiptHeader);
                end;
            end;
        end;
    end;

    #endregion UserClickOnChart
}
