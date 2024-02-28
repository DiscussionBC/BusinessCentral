Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnStartup')

window.loaddata = function (data) {    
    var iframe = document.getElementById('controlAddIn');    
    iframe.innerHTML = data;        
    
    var bootstraps = iframe.querySelectorAll('a');
    
    bootstraps.forEach(function(bootstrap) {                       
        bootstrap.addEventListener('click', function() {
            var bootId = this.id;
            console.log('Pulsado ' + bootId);
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('buttonclick',[bootId]);                        
        });
    });
}