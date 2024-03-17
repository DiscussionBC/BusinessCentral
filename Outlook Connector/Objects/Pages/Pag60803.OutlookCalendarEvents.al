page 60803 OutlookCalendar
{
    ApplicationArea = All;
    Caption = 'Eventos calendario Outlook';
    PageType = List;
    SourceTable = Calendars;
    UsageCategory = Lists;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(Calendars)
            {
                Caption = 'Calendarios';
                repeater(General)
                {

                    field(Id; Rec.Id)
                    {
                        Visible = false;
                    }
                    field(Name; Rec.Name)
                    { }
                    field(IsDefault; Rec.IsDefault)
                    { }
                }
            }
            group(ProdOrders)
            {
                Caption = 'Órdenes de producción';
                part(ProdOrderLines; "Released Prod. Order Lines")
                {
                }
            }
            group(Events)
            {
                Caption = 'Eventos';
                usercontrol(calendar; calendar)
                {
                    trigger OnStartCalendar()
                    begin
                        DrawCalendar();
                    end;

                    trigger EventModified(eventTxt: Text; startDateTime: DateTime; endDateTime: DateTime; eventId: Text; allDay: Boolean)
                    var
                        Error001: Label 'No pudo ser modificado';
                    begin
                        if not GraphConnectorMngt.ModifyEvent(eventId, startDateTime, endDateTime, allDay) then begin
                            Message(Error001);
                            DrawCalendar();
                        end;
                    end;
                }
            }
            usercontrol(childparentpagecomm; childparentpagecomm)
            {
                trigger ReloadCalendar(prodlineid: Text)
                var
                    ProdOrderLine: Record "Prod. Order Line";
                    ProdOrderLineRecID: RecordId;
                    Body: Label '%1 %2 %3';
                    Error001: Label 'El evento no pudo ser creado en el calendario %1';
                begin
                    Evaluate(ProdOrderLineRecID, prodlineid);
                    if ProdOrderLine.Get(ProdOrderLineRecID) then
                        if GraphConnectorMngt.NewEvent(Rec.Id, ProdOrderLine.Description, StrSubstNo(Body, ProdOrderLine.Description, ProdOrderLine.Quantity, ProdOrderLine."Unit of Measure Code"), ProdOrderLine."Starting Date-Time", ProdOrderLine."Ending Date-Time", false) then
                            DrawCalendar(ProdOrderLine."Starting Date")
                        else
                            Error(Error001, Rec.Name);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange(UserGuid, UserSecurityId());
        GraphConnectorMngt.GetAllCalendars();
        CurrPage.Update(false);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.ProdOrderLines.Page.SetCalendar();
        DrawCalendar();
    end;

    var
        GraphConnectorMngt: Codeunit GraphConnectorMngt;
        EventsJArray: JsonArray;

    local procedure DrawCalendar()
    begin
        DrawCalendar(Today);
    end;

    local procedure DrawCalendar(startingdate: Date)
    begin
        DrawMyCalendar(startingdate);
    end;

    local procedure DrawMyCalendar(startingdate: Date)
    begin
        EventsJArray := GraphConnectorMngt.GetCalendarEvents(Rec.Id);
        CurrPage.calendar.SetCalendarData(EventsJArray, FORMAT(startingdate, 0, 9));
    end;
}
