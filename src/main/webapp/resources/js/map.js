let map;
let vehicleMarkers = new Map();
let websocket;

function initMap() {
    // Initialize Leaflet map
    map = L.map('map').setView([-1.300294, 36.860235], 14);

    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&#169; OpenStreetMap contributors'
    }).addTo(map);

    // Initialize WebSocket
    websocket = new WebSocket('ws://localhost:34251/tracking');

    websocket.onmessage = function (event) {
        const data = JSON.parse(event.data);
        console.log(data);
        updateVehiclePosition(data);
    };
}

function updateVehiclePosition(vehicle) {
    const latLng = [vehicle.lat, vehicle.lng];

    if (!vehicleMarkers.has(vehicle.driverId)) {
        // Create new marker
        const marker = L.marker(latLng, {
            icon: L.icon({
                iconUrl: vehicle.inZone ?
                        '#{resource["leaflet:images/green-car.png"]}' :
                        '#{resource["leaflet:images/red-car.png"]}',
                iconSize: [32, 32],
                iconAnchor: [16, 32]
            })
        }).addTo(map);

        vehicleMarkers.set(vehicle.driverId, marker);
    } else {
        // Smooth transition for existing marker
        const marker = vehicleMarkers.get(vehicle.driverId);
        const oldPos = marker.getLatLng();
        const newPos = L.latLng(latLng);

        // Animate marker movement
        marker.setLatLng(newPos);
        marker.setIcon(L.icon({
            iconUrl: vehicle.inZone ?
                    '#{resource["leaflet:images/green-car.png"]}' :
                    '#{resource["leaflet:images/red-car.png"]}',
            iconSize: [32, 32],
            iconAnchor: [16, 32]
        }));
    }

    // Update UI
    document.getElementById('lastUpdate').textContent =
            new Date().toLocaleTimeString();
}

// Initialize map on window load
window.addEventListener('load', initMap);

// Reconnect if connection closes
function reconnect() {
    setTimeout(() => {
        websocket = new WebSocket('ws://localhost:34251/Nganya/tracking');
        websocket.onopen = () => location.reload();
    }, 5000);
}

websocket.onclose = reconnect;