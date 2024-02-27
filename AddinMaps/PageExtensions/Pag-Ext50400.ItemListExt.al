pageextension 50400 ItemListExt extends "Item List"
{
    layout
    {
        addlast(Control1)
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
