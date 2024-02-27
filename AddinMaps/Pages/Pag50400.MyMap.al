page 50400 MyMap
{
    ApplicationArea = All;
    Caption = 'My Map';
    PageType = List;
    SourceTable = Item;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Unit Price"; Rec."Unit Price")
                {
                }
                field(Longitude; Rec.Longitude)
                {
                }
                field(Latitude; Rec.Latitude)
                {
                }
                field("Show in map"; Rec."Show in map")
                {
                }
                field("Map description"; Rec."Map description")
                {
                }
            }
            group(Mapa)
            {
                usercontrol(MyMap; MyMap)
                {
                    ApplicationArea = All;
                    trigger OnStartup()
                    begin
                        CurrPage.MyMap.PassCoords(JArray);
                    end;

                    trigger SendCoords(latitude: Text; longitude: Text)
                    var
                        Msg001: Label 'El inmueble %1 ya tiene coordenadas ¿desea sustituirlas?';
                    begin
                        if (Rec.Latitude <> '') or (Rec.Longitude <> '') then
                            if not Confirm(StrSubstNo(Msg001, Rec.Description)) then exit;
                        Rec.Latitude := latitude;
                        Rec.Longitude := longitude;
                        Rec.Modify(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        JObject: JsonObject;
    begin
        if (Rec.Longitude <> '') and (Rec.Latitude <> '') and (REc."Show in map") then begin
            Clear(JObject);
            JObject.Add('lat', Rec.Latitude);
            JObject.Add('lng', Rec.Longitude);
            JObject.Add('BcText', Rec."Map description");
            JArray.Add(JObject);
        end;
    end;

    var
        JArray: JsonArray;
}
