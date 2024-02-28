page 50400 "Button Test"
{
    ApplicationArea = All;
    Caption = 'Prueba botones';
    PageType = Card;
    UsageCategory = Tasks;


    layout
    {
        area(content)
        {
            usercontrol(botonera; buttons)
            {
                trigger OnStartup()
                begin
                    SetBootstrapButtonData();
                end;

                trigger buttonclick(data: Text)
                begin
                    case data of
                        '1':
                            SetBootstrapButtonData();
                        '2':
                            SetBootstrapButtonData2();
                        '3':
                            SetBootstrapButtonData3();
                        else
                            Message('Pulsado botón ' + data);
                    end;
                end;
            }
        }
    }

    var
        InitDiv: Label '<div class="container"><div class="row"><div class="col-lg-12"><p>';
        ButtonSource: Label '<a href="#" id="%1" class="btn btn-sq-lg btn-primary"><i class="fas %2 fa-2x"></i><br/><br/>%3<br>%4</a>';
        ButtonSource2: Label '<a href="#" id="%1" class="btn btn-sq-lg btn-success"><i class="fas %2 fa-2x"></i><br/><br/>%3<br>%4</a>';
        ButtonSource3: Label '<a href="#" id="%1" class="btn btn-sq-lg btn-info"><i class="fas %2 fa-2x"></i><br/><br/>%3<br>%4</a>';
        EndDiv: Label '</p></div></div>';

    local procedure SetBootstrapButtonData()
    var
        TextBuilder: TextBuilder;
    begin
        TextBuilder.Append(InitDiv);
        TextBuilder.Append(StrSubstNo(ButtonSource, '1', 'fa-list', 'Lista', 'productos'));
        TextBuilder.Append(StrSubstNo(ButtonSource, '2', 'fa-calendar-days', 'Planif.', 'producción'));
        TextBuilder.Append(StrSubstNo(ButtonSource, '3', 'fa-print', 'Imprimir', 'etiquetas'));
        TextBuilder.Append(StrSubstNo(ButtonSource, '4', 'fa-truck', 'Ver carga', 'camión'));
        TextBuilder.Append(StrSubstNo(ButtonSource, '5', 'fa-industry', 'Comenzar', 'picking'));
        TextBuilder.Append(EndDiv);

        CurrPage.botonera.loaddata(TextBuilder.ToText());
    end;

    local procedure SetBootstrapButtonData2()
    var
        TextBuilder: TextBuilder;
    begin
        TextBuilder.Append(InitDiv);
        TextBuilder.Append('<div>');
        TextBuilder.Append(StrSubstNo(ButtonSource2, '1', 'fa-list', 'Lista', 'productos'));
        TextBuilder.Append(StrSubstNo(ButtonSource2, '2', 'fa-calendar-days', 'Planif.', 'producción'));
        TextBuilder.Append(StrSubstNo(ButtonSource2, '3', 'fa-print', 'Imprimir', 'etiquetas'));
        TextBuilder.Append('</div><div>');
        TextBuilder.Append(StrSubstNo(ButtonSource2, '4', 'fa-truck', 'Ver carga', 'camión'));
        TextBuilder.Append(StrSubstNo(ButtonSource2, '5', 'fa-industry', 'Comenzar', 'picking'));
        TextBuilder.Append('</div>');
        TextBuilder.Append(EndDiv);

        CurrPage.botonera.loaddata(TextBuilder.ToText());
    end;

    local procedure SetBootstrapButtonData3()
    var
        TextBuilder: TextBuilder;
    begin
        TextBuilder.Append(InitDiv);
        TextBuilder.Append(StrSubstNo(ButtonSource3, '1', 'fa-list', 'Lista', 'productos'));
        TextBuilder.Append(StrSubstNo(ButtonSource3, '2', 'fa-calendar-days', 'Planif.', 'producción'));
        TextBuilder.Append(StrSubstNo(ButtonSource3, '3', 'fa-print', 'Imprimir', 'etiquetas'));
        TextBuilder.Append(StrSubstNo(ButtonSource3, '4', 'fa-truck', 'Ver carga', 'camión'));
        TextBuilder.Append(StrSubstNo(ButtonSource3, '5', 'fa-industry', 'Comenzar', 'picking'));
        TextBuilder.Append(EndDiv);

        CurrPage.botonera.loaddata(TextBuilder.ToText());
    end;
}