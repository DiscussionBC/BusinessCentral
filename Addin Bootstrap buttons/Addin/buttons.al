controladdin buttons
{
    MinimumHeight = 600;
    MinimumWidth = 200;
    RequestedHeight = 600;
    RequestedWidth = 200;
    HorizontalShrink = true;
    HorizontalStretch = true;
    VerticalShrink = true;
    VerticalStretch = true;

    StartupScript = './Addin/startup.js';
    Scripts = 'https://code.jquery.com/jquery-3.7.1.min.js', 'https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.3/js/bootstrap.min.js';
    StyleSheets = './Addin/buttons.css', 'https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.3/css/bootstrap.min.css', 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css';

    event buttonclick(data: Text);
    event OnStartup();

    procedure loaddata(data: Text);
}