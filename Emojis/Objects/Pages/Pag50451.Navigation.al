page 50451 Navigation
{
    ApplicationArea = All;
    Caption = 'Emoji navigation';
    PageType = NavigatePage;
    SourceTable = "Integer";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Previous)
            {
                Caption = '➖';
                Image = none;
                InFooterBar = true;

                trigger OnAction()
                begin
                    Message('Previo');
                end;
            }
            action(Next)
            {
                Caption = '➕';
                Image = none;
                InFooterBar = true;

                trigger OnAction()
                begin
                    Message('Siguiente');
                end;
            }

        }
    }
}
