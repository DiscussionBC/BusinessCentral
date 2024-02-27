pageextension 50401 ItemCardExt extends "Item Card"
{
    layout
    {
        addlast(content)
        {
            group(Map)
            {
                field(Longitude; Rec.Longitude)
                { }
                field(Latitude; Rec.Latitude)
                { }
                field("Map description"; Rec."Map description")
                { }
                field("Show in map"; Rec."Show in map")
                { }
            }
        }
    }
}
