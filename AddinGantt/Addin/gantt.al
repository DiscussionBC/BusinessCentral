controladdin "gantt"
{
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    RequestedWidth = 500;
    RequestedHeight = 600;

    Scripts = './Addin/frappe-gantt.min.js';
    StartupScript = './Addin/startup.js';
    StyleSheets = './Addin/frappe-gantt.min.css';

    event Ready();
    procedure initgraph(tasks: JsonArray);
    event datechanged(task: Text; startdate: Text; enddate: Text);
    event progresschanged(task: Text; progress: Decimal);
}