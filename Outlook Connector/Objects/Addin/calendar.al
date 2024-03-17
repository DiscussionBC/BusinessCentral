controladdin calendar
{
    RequestedHeight = 700;
    RequestedWidth = 700;
    MinimumHeight = 700;
    MinimumWidth = 700;
    MaximumWidth = 700;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    Scripts = 'https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js', 'https://unpkg.com/popper.js/dist/umd/popper.min.js', './Objects/Addin/es.global.min.js', 'https://unpkg.com/tooltip.js/dist/umd/tooltip.min.js';
    StartupScript = './Objects/Addin/calendar.js';
    StyleSheets = './Objects/Addin/calendar.css';

    procedure SetCalendarData(Data: JsonArray; workDate: Text);
    event OnStartCalendar();
    event EventModified(eventTxt: Text; startDateTime: DateTime; endDateTime: DateTime; eventId: Text; allDay: Boolean);
}

controladdin childparentpagecomm
{
    MaximumHeight = 1;
    MaximumWidth = 1;
    MinimumHeight = 1;
    MinimumWidth = 1;
    RequestedHeight = 1;
    RequestedWidth = 1;

    Scripts = './Objects/Addin/childparentpagecomm.js';

    event ReloadCalendar(prodlineid: Text);
    procedure EventCreated(prodlineid: Text);
}