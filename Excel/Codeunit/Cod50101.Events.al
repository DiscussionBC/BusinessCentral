codeunit 50101 Events
{
    [EventSubscriber(ObjectType::Table, Database::"Excel Buffer", 'OnBeforeParseCellValue', '', false, false)]
    local procedure OnBeforeParseCellValue(var ExcelBuffer: Record "Excel Buffer"; var Value: Text; var FormatString: Text; var IsHandled: Boolean)
    var
        OutStream: OutStream;
        Decimal: Decimal;
        RoundingPrecision: Decimal;
        MyDateTime: DateTime;
    begin
        IsHandled := true;
        ExcelBuffer.NumberFormat := CopyStr(FormatString, 1, 30);

        Clear(ExcelBuffer."Cell Value as Blob");
        if FormatString = '@' then begin
            ExcelBuffer."Cell Type" := ExcelBuffer."Cell Type"::Text;
            ExcelBuffer.MyType := ExcelBuffer.MyType::Text;
            ExcelBuffer."Cell Value as Text" := CopyStr(Value, 1, MaxStrLen(ExcelBuffer."Cell Value as Text"));

            if StrLen(Value) <= MaxStrLen(ExcelBuffer."Cell Value as Text") then
                exit; // No need to store anything in the blob

            ExcelBuffer."Cell Value as Blob".CreateOutStream(OutStream, TEXTENCODING::Windows);
            OutStream.Write(Value);
            exit;
        end;

        Evaluate(Decimal, Value);

        if StrPos(FormatString, ':') <> 0 then begin
            // Excel Time is stored in OADate format
            //If cell  format is DateTime
            if (StrPos(FormatString, 'y') <> 0) then begin
                ExcelBuffer."Cell Type" := ExcelBuffer."Cell Type"::Text;
                ExcelBuffer.MyType := ExcelBuffer.MyType::DateTime;
                MyDateTime := ExcelBuffer.ConvertDateTimeDecimalToDateTime(Decimal);
                ExcelBuffer."Cell Value as Text" := Format(MyDateTime);
            end else begin
                //If cell  format is Time
                ExcelBuffer."Cell Type" := ExcelBuffer."Cell Type"::Time;
                ExcelBuffer.MyType := ExcelBuffer.MyType::Time;
                ExcelBuffer."Cell Value as Text" := Format(DT2Time(ExcelBuffer.ConvertDateTimeDecimalToDateTime(Decimal)));
            end;
            exit;
        end;

        if ((StrPos(FormatString, 'y') <> 0) or
            (StrPos(FormatString, 'm') <> 0) or
            (StrPos(FormatString, 'd') <> 0)) and
           (StrPos(FormatString, 'Red') = 0)
        then begin
            ExcelBuffer."Cell Type" := ExcelBuffer."Cell Type"::Date;
            ExcelBuffer.MyType := ExcelBuffer.MyType::Date;
            ExcelBuffer."Cell Value as Text" := Format(DT2Date(ExcelBuffer.ConvertDateTimeDecimalToDateTime(Decimal)));
            exit;
        end;

        ExcelBuffer."Cell Type" := ExcelBuffer."Cell Type"::Number;
        ExcelBuffer.MyType := ExcelBuffer.MyType::Number;
        RoundingPrecision := 0.000001;
        ExcelBuffer."Cell Value as Text" := Format(Round(Decimal, RoundingPrecision), 0, 1);
    end;
}
