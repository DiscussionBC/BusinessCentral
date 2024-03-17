function EventCreated(prodlineid)
{    
    try
    {
        for(var i = 0; i < window.parent.frames.length; i++){
            if(window.frameElement != window.parent.frames[i].frameElement)
                if (window.parent.frames[i].frameElement.contentWindow.EventCreated != null)
                    window.parent.frames[i].frameElement.contentWindow.SendReload(prodlineid);                
        }
        
    }
    catch(ex)
    {
        console.log(ex);
    }
}

function SendReload(prodlineid)
{
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ReloadCalendar',[prodlineid]); 
}    