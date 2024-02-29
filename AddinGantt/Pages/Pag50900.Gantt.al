page 50900 Gantt
{
    ApplicationArea = All;
    Caption = 'Gantt';
    PageType = Card;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                ShowCaption = false;
                usercontrol(gantt; gantt)
                {
                    trigger Ready()
                    begin
                        CurrPage.gantt.initgraph(JArray);
                    end;

                    trigger datechanged(task: Text; startdate: Text; enddate: Text)
                    var
                        Msg001: Label 'El evento %1 ha modificado sus fechas a inicio: %2 fin:%3';
                    begin
                        Message(StrSubstNo(Msg001, task, startdate, enddate));
                    end;

                    trigger progresschanged(task: Text; progress: Decimal)
                    var
                        Msg001: Label 'El evento %1 ha modificado sus progreso a %2 %';
                    begin
                        Message(StrSubstNo(Msg001, task, progress));
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        JObject: JsonObject;
    begin
        Job.SetLoadFields("Starting Date", "Ending Date", Description, "No.");
        if Job.FindSet() then
            repeat
                Clear(JObject);
                JObject.Add('start', FORMAT(Job."Starting Date", 0, 9));
                JObject.Add('end', FORMAT(Job."Ending Date", 0, 9));
                JObject.Add('name', Job.Description);
                JObject.Add('id', Job."No.");
                JObject.Add('progress', Job.PercentCompleted());
                JArray.Add(JObject);
                JobTask.Reset();
                JobTask.SetRange("Job No.", Job."No.");
                JobTask.SetRange("Job Task Type", JobTask."Job Task Type"::Posting);
                JobTask.SetLoadFields("Start Date", "End Date", Description, "Job Task No.");
                if JobTask.FindSet() then
                    repeat
                        Clear(JObject);
                        JobTask.CalcFields("Start Date", "End Date");
                        JObject.Add('start', FORMAT(JobTask."Start Date", 0, 9));
                        JObject.Add('end', FORMAT(JobTask."End Date", 0, 9));
                        JObject.Add('name', JobTask.Description);
                        JObject.Add('id', JobTask."Job Task No.");
                        JObject.Add('progress', Job.PercentCompleted());
                        JObject.Add('dependencies', Job."No.");
                        JArray.Add(JObject);
                    until JobTask.Next() = 0;
            until job.Next() = 0;
    end;

    var
        JArray: JsonArray;
}
