page 50200 "Sound test"
{
    ApplicationArea = All;
    Caption = 'Sound test';
    PageType = Card;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                usercontrol(CreateSound; CreateSound)
                {

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(a1)
            {
                Caption = 'Probar sonido';
                Image = ViewComments;

                trigger OnAction()
                begin
                    CurrPage.CreateSound.beep();
                end;
            }
        }
        area(Promoted)
        {
            actionref(aa1; a1) { }
        }
    }
}
