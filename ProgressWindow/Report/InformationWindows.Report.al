report 60100 "Information Windows"
{
    Caption = 'Ventana de información';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 .. 5000000)); //30 segundos aprox.
            trigger OnPreDataItem()
            begin
                case DialogOptions of
                    DialogOptions::"Progress Bar 1":
                        begin
                            Window.Open(
                                Text000Lbl +
                                Text001Lbl +
                                Text002Lbl);
                            Linea := 0;
                            Registros := Count();
                        end;
                    DialogOptions::"Progress Bar 2":
                        begin
                            Window.Open(
                                Text000Lbl +
                                Text001Lbl +
                                Text002Lbl);
                            Linea := 0;
                            Registros := Count();
                        end;
                    DialogOptions::"Progress Bar 3":
                        begin
                            Window.Open(
                                Text000Lbl +
                                Text001Lbl +
                                Text002Lbl);
                            Linea := 0;
                            Registros := Count();
                        end;
                    DialogOptions::"Estimated Time 1":
                        begin
                            Window.Open(
                                Text000Lbl +
                                Text001Lbl +
                                Text003Lbl);
                            Inicio := CurrentDateTime();
                            Linea := 0;
                            Registros := Count();
                        end;
                    DialogOptions::"Estimated Time 2":
                        begin
                            Window.Open(
                                Text000Lbl +
                                Text001Lbl +
                                Text003Lbl);
                            Inicio := CurrentDateTime();
                            Linea := 0;
                            Registros := Count();
                        end;
                    DialogOptions::Calcultating:
                        begin
                            Window.Open(
                                Text000Lbl +
                                Text001Lbl +
                                Text004Lbl);
                            TiempoIni := Time;
                            CaracterIni := '|';
                            Linea := 0;
                            Registros := Count();
                        end;

                end;
            end;

            trigger OnAfterGetRecord()
            begin
                case DialogOptions of
                    DialogOptions::"Progress Bar 1":
                        begin
                            Linea += 1;
                            Window.Update(1, Format(Integer));
                            Window.Update(2, ProgressBar(Round((Linea / Registros) * 20, 1)));
                        end;
                    DialogOptions::"Progress Bar 2":
                        begin
                            Linea += 1;
                            Window.Update(1, Format(Integer));
                            Window.Update(2, ProgressBar(Round((Linea / Registros) * 20, 1)) + ' ' + Format(Linea) + ' / ' + Format(Registros));
                        end;
                    DialogOptions::"Progress Bar 3":
                        begin
                            Linea += 1;
                            Window.Update(1, Format(Integer));
                            Window.Update(2, ProgressBar(Round((Linea / Registros) * 20, 1)) + ' ' + Percentage(Linea, Registros));
                        end;
                    DialogOptions::"Estimated Time 1":
                        begin
                            Linea += 1;
                            Window.Update(1, Format(Integer));
                            Window.Update(2, EstimationEnd(Inicio, Linea, Registros));
                        end;
                    DialogOptions::"Estimated Time 2":
                        begin
                            Linea += 1;
                            Window.Update(1, Format(Integer));
                            Window.Update(2, EstimationEnd2(Inicio, Linea, Registros));
                        end;
                    DialogOptions::Calcultating:
                        begin
                            Linea += 1;
                            Window.Update(1, Format(Integer));
                            Window.Update(2, DoingSomething(TiempoIni, CaracterIni));
                        end;
                end;
            end;

            trigger OnPostDataItem()
            begin
                Window.Close();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Opciones';
                    field(DialogOptionsLbl; DialogOptions)
                    {
                        Caption = 'Opciones de diálogo';
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
    var
        DialogOptions: Enum "Dialog Options";
        Window: Dialog;
        Linea: Integer;
        Registros: Integer;
        Inicio: DateTime;
        TiempoIni: Time;
        CaracterIni: Text[1];
        Text000Lbl: Label 'Generando informe...\\';
        Text001Lbl: Label 'Registro    #1###############\';
        Text002Lbl: Label 'Progreso    #2###############';
        Text003Lbl: Label 'Finaliza a las #2################';
        Text004Lbl: Label 'Calculando  #2####';

    local procedure ProgressBar(Contador: Integer): Text
    var
        Factor: Decimal;
        TextBar: Text;
        I: Integer;
    begin
        Factor := Round(Contador / 1, 1, '<');
        TextBar := '';
        for I := 1 to 20 do begin //Longitud de la barra 20 caracteres
            if I <= Factor then
                TextBar += '█'
            else
                TextBar += '░';
        end;
        exit(TextBar);
    end;

    local procedure Percentage(Valor1: Decimal; Valor2: Decimal): Text
    var
        Result: Decimal;
    begin
        if Valor2 > 0 then begin
            Result := Round(Valor1 * 100 / Valor2, 1);
            exit(Format(Result) + ' %');
        end else
            exit('');
    end;

    local procedure EstimationEnd(FechaHoraBase: DateTime; LineaProcesada: Integer; Registro: Integer): Text
    var
        MLTrascurridos: BigInteger;
        MLEstimados: BigInteger;
        NuevaFechaHora: DateTime;
    begin
        MLTrascurridos := CurrentDateTime - FechaHoraBase;
        MLEstimados := Round(MLTrascurridos * (1 / (LineaProcesada / Registro)), 1);

        NuevaFechaHora := FechaHoraBase + MLEstimados;

        exit(Format(NuevaFechaHora));
    end;

    local procedure EstimationEnd2(FechaHoraBase: DateTime; LineaProcesada: Integer; Registro: Integer): Text
    var
        MLTrascurridos: BigInteger;
        MLEstimados: BigInteger;
        NuevaFechaHora: DateTime;
    begin
        MLTrascurridos := CurrentDateTime - FechaHoraBase;
        MLEstimados := Round(MLTrascurridos * (1 / (LineaProcesada / Registro)), 1);

        NuevaFechaHora := FechaHoraBase + MLEstimados;

        exit(Format(DT2Time(NuevaFechaHora)));
    end;

    local procedure DoingSomething(var TiempoRef: Time; var Caracter: Text[1]): Text
    var
        Text01Lbl: Label '(';
        Text02Lbl: Label ')';
    begin
        if (Time - TiempoRef) > 200 then begin//0,2 segundo
            case Caracter of
                '|':
                    begin
                        TiempoRef := Time;
                        Caracter := '/';
                    end;
                '/':
                    begin
                        TiempoRef := Time;
                        Caracter := '—';
                    end;
                '—':
                    begin
                        TiempoRef := Time;
                        Caracter := '\';
                    end;
                '\':
                    begin
                        TiempoRef := Time;
                        Caracter := '|';
                    end;
            end;
        end;
        exit(Text01Lbl + Format(Caracter) + Text02Lbl);
    end;
}