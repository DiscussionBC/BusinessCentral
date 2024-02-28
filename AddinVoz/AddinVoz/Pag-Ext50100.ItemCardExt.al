pageextension 50100 ItemCardExt extends "Item Card"
{
    layout
    {
        addlast(content)
        {
            usercontrol(voice; voice)
            {
                trigger voice(listenedText: Text)
                begin
                    LongText := listenedText;
                    CurrPage.Update(false);
                end;
            }
            field(LongText; LongText)
            {
                Caption = 'Texto dictado';
                Editable = true;
                MultiLine = true;

                trigger OnAssistEdit()
                begin
                    CurrPage.voice.startrecording();
                end;
            }
            usercontrol(LongText2; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = All;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    SetAddInContent();
                end;

                trigger Callback(data: Text)
                begin
                    LongText := data;
                end;
            }
        }
    }


    var
        LongText: Text;

    local procedure SetAddInContent()
    begin
        CurrPage.LongText2.SetContent(StrSubstNo('<textarea Id="TextArea" maxlength="%2" style="width:100%;height:100%; font-family:"Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important; font-size: 10.5pt !important;" OnChange="window.parent.WebPageViewerHelper.TriggerCallback(document.getElementById(''TextArea'').value)">%1</textarea>', LongText, 5000));
    end;
}
