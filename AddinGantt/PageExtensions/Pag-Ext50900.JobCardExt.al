pageextension 50900 JobCardExt extends "Job Card"
{
    layout
    {
        addafter(JobTaskLines)
        {
            group(Gantt)
            {
                usercontrol(mygantt; gantt)
                {
                    trigger Ready()
                    begin
                        CurrPage.mygantt.initgraph(JArray);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        JobTask: Record "Job Task";
        JObject: JsonObject;
    begin
        Clear(JObject);
        JObject.Add('start', FORMAT(Rec."Starting Date", 0, 9));
        JObject.Add('end', FORMAT(Rec."Ending Date", 0, 9));
        JObject.Add('name', Rec.Description);
        JObject.Add('id', Rec."No.");
        JObject.Add('progress', Rec.PercentCompleted());
        JArray.Add(JObject);
        JobTask.Reset();
        JobTask.SetRange("Job No.", Rec."No.");
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
                JObject.Add('progress', Rec.PercentCompleted());
                JObject.Add('dependencies', Rec."No.");
                JArray.Add(JObject);
            until JobTask.Next() = 0;
    end;

    var
        JArray: JsonArray;
}
