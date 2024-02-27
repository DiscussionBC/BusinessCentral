Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnStartup')

// Where you want to render the map.
var element = document.getElementById('controlAddIn');

// Height has to be set. You can do this in CSS too.
element.style = 'height:500px;';

// Create Leaflet map on map element.
var map = L.map(element);

// Add OSM tile layer to the Leaflet map.
L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// Target's GPS coordinates.
var target = L.latLng('43.3674914', '-8.4043295');

map.setView(target, 14);

  map.on('click', function(e){
    var coord = e.latlng;
    var lat = coord.lat;
    var lng = coord.lng;
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('SendCoords',[lat.toString(),lng.toString()]);        
    });

    
 window.PassCoords =function(data) {
    for (var position of data) {   
        console.log(position);
        var myLatLng = new L.latLng(position.lat,position.lng);
        var lat = myLatLng.lat.toPrecision(8);
        var lon = myLatLng.lng.toPrecision(8);
        marker = new L.marker(myLatLng).addTo(map).bindPopup(position.BcText).openPopup();

        
        let isClicked = false

        marker.on({
            mouseover: function() {
                if(!isClicked) {
                    this.openPopup()
                }
            },
            mouseout: function() { 
                if(!isClicked) {
                    this.closePopup()
                }
            },
            click: function() {
                isClicked = true
                this.openPopup()
            }
        })

        map.on ({
            click: function() {
                isClicked = false
            },
            popupclose: function () {
                isClicked = false
            }
        })
    };
};