pageextension 60800 RelProdOrdLines extends "Released Prod. Order Lines"
{
    layout
    {
        addlast(content)
        {
            usercontrol(childparentpagecomm; childparentpagecomm)
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action(add2calendar)
            {
                ApplicationArea = All;
                Caption = 'Añadir como evento a calendario Outlook';
                Image = CalendarWorkcenter;
                Scope = Repeater;
                Visible = OutlookCalendar;

                trigger OnAction()
                begin
                    if OutlookCalendar then
                        CurrPage.childparentpagecomm.EventCreated(Format(Rec.RecordId));
                end;
            }
        }
    }

    var
        OutlookCalendar: Boolean;

    procedure SetCalendar()
    begin
        OutlookCalendar := true;
    end;
}
