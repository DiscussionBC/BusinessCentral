table 60801 Calendars
{
    Caption = 'Calendarios';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Id; Text[250])
        {
            Caption = 'Id';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Nombre';
        }
        field(3; Colour; Text[10])
        {
            Caption = 'Color';
        }
        field(4; UserGuid; Guid)
        {
            Caption = 'Id usuario';
        }
        field(5; IsDefault; Boolean)
        {
            Caption = 'Calendario principal';
        }
    }
    keys
    {
        key(PK; Id, UserGuid)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Id, Name)
        {
        }
    }
}
