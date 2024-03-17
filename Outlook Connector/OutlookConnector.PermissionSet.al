permissionset 60800 OutlookConnector
{
    Assignable = true;
    Permissions = tabledata Calendars = RIMD,
        tabledata GraphSetup = RIMD,
        table Calendars = X,
        table GraphSetup = X,
        codeunit GraphConnectorMngt = X,
        page "Graph setup" = X,
        page OAuth2Dialog = X,
        page OutlookCalendar = X;
}