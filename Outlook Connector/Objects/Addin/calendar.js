Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnStartCalendar')
window.SetCalendarData = function (data,workdate) {
  try { 
        var div = document.getElementById('controlAddIn');      
        div.innerHTML += `<div id='calendar-wrap' style="max-width: 1600px;margin: 0 auto;">    
          <div id='calendar' style="max-width: 1600px;margin: 0 auto;"></div></div>`;        
          calendarEl = document.getElementById('calendar-wrap');
          var calendar = new FullCalendar.Calendar(calendarEl, {
            headerToolbar: {
              left: 'prev,next today',
              center: 'title',
              right: 'dayGridMonth,timeGridWeek,listWeek,timeGridDay'
            },
            initialDate: workdate,            
            locale: 'es',
            buttonIcons: false, // show the prev/next text
            weekNumbers: false,
            weekNumberCalculation: 'ISO',
            navLinks: true, // can click day/week names to navigate views
            editable: true,
            dayMaxEvents: true, // allow "more" link when too many events      
            eventDidMount: function(info) {              
              var tooltip = new Tooltip(info.el, {
                title: info.event.extendedProps.description,
                placement: 'top',
                trigger: 'hover',
                container: 'body'
              });                
            },            
            eventResize: function(info) {      
              //alert(info.event.title + " was resized on " + info.event.start.toISOString());         
              if (info.event.allDay)
              {   
                console.log(info);
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('EventModified',[info.event.title.toString(),info.event.start,info.event.end,info.event.id.toString(),true])        
              }
              else
              {
                console.log(info);
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('EventModified',[info.event.title.toString(),info.event.start,info.event.end,info.event.id.toString(),false])        
              }
            },
            eventDrop: function(info) {                 
              if (info.event.allDay)
              {    
                if (info.event.endStr != '')
                {              
                  console.log(info);
                 Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('EventModified',[info.event.title.toString(),info.event.start,info.event.end,info.event.id.toString(),true])        
                }
                else
                {
                  console.log(info);
                   Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('EventModified',[info.event.title.toString(),info.event.start,info.event.extendedProps.bcendevent,info.event.id.toString(),true])          
                }
              }          
              else
              {                     
                console.log(info);
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('EventModified',[info.event.title.toString(),info.event.start,info.event.end,info.event.id.toString(),false])        
              }
            },
            events: data
          });

    calendar.render();
  } catch (err) {
    console.log(err);
}
}
