controladdin "Voice"
{
    RequestedHeight = 0;
    RequestedWidth = 0;
    Scripts = './AddinVoz/startup.js';

    event ReadyVoice();
    procedure stoprecording();
    procedure startrecording();
    procedure speak(listenTxt: Text);

    event voice(listenedText: Text);
}