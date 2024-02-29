Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('Ready');

window.initgraph = function(tasks){
    try{                       
            element = document.getElementById('controlAddIn');
            element.innerHTML = `<div class="container">                
                <div class="gantt-target"></div>
            </div>`;

            var gantt_chart = new Gantt(".gantt-target", tasks, {
                on_click: task => {                    
                    console.log(task);
                },
                on_date_change: (task, start, end) => {
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('datechanged',[task.name, start, end]); 
                    console.log(task, start, end);
                },
                on_progress_change: (task, progress) => {
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('progresschanged',[task.name, progress]); 
                    console.log(task, progress);
                },
                on_view_change: (mode) => {
                    console.log(mode);
                },
                view_mode: 'Month',
                language: 'es'
            });


    } catch (err) {
        console.log(err);
    }
}