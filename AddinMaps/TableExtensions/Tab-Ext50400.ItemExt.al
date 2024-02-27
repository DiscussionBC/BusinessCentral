tableextension 50400 ItemExt extends item
{
    fields
    {
        field(50000; Longitude; Text[20])
        {
            Caption = 'Longitud';
            DataClassification = ToBeClassified;
        }
        field(50001; Latitude; Text[20])
        {
            Caption = 'Latitud';
            DataClassification = ToBeClassified;
        }
        field(50002; "Show in map"; Boolean)
        {
            Caption = 'Mostrar en mapa';
            DataClassification = ToBeClassified;
        }
        field(50003; "Map description"; Text[150])
        {
            Caption = 'Descripción en mapa';
            DataClassification = ToBeClassified;
        }
    }
}
