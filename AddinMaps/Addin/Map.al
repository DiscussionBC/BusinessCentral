controladdin MyMap
{
    RequestedHeight = 500;
    RequestedWidth = 350;
    MinimumHeight = 500;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    StartupScript = './Addin/startup.js';

    Scripts = 'https://unpkg.com/leaflet@1.6.0/dist/leaflet.js';
    StyleSheets = 'https://unpkg.com/leaflet@1.6.0/dist/leaflet.css';

    event OnStartup();
    event SendCoords(latitude: Text; longitude: Text);

    procedure PassCoords(data: JsonArray);
}