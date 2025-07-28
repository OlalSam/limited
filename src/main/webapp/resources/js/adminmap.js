// ---------- Driver-side Map ----------

// Driver-side map JavaScript (driverMap.js)
const initDriverMap = () => {
    // Set your Mapbox access token
    mapboxgl.accessToken = 'pk.eyJ1Ijoib2xhbCIsImEiOiJjbThidjM5aTgxcDNtMm1zNTh6NjRqeDE3In0.EIobbUYeWUFMarhuxGr_sg';

    // Initialize the Mapbox map centered on a default location (adjustable)
    const map = new mapboxgl.Map({
        container: 'driverMap', // Container ID
        style: 'mapbox://styles/mapbox/streets-v11',
        center: [36.860235, -1.300294], // Default coordinates (Nairobi)
        zoom: 12 // Starting zoom level
    });

    // Add navigation controls (zoom and rotation)
    map.addControl(new mapboxgl.NavigationControl());

    // WebSocket setup
    const origin = window.location.origin;
    const websocketProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = websocketProtocol + '//' + window.location.host + '/Nganya/tracking';
    const websocket = new WebSocket(wsUrl);

    // Set up geofence data - shared with admin map
    const geofences = {
        "largeZone": {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                        [36.793850, -1.268661], [36.868210, -1.234116],
                        [36.939121, -1.323920], [36.863803, -1.358592],
                        [36.793850, -1.268661]
                    ]]
            }
        },
        "CBD": {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                        [36.814932, -1.283793], [36.834377, -1.278729],
                        [36.841615, -1.287849], [36.819990, -1.297579],
                        [36.814932, -1.283793]
                    ]]
            }
        },
        "StageEmbakasi": {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                        [36.892297, -1.315585], [36.903495, -1.315585],
                        [36.903495, -1.330043], [36.892297, -1.330043],
                        [36.892297, -1.315585]
                    ]]
            }
        }
    };

    // Add geofence layers to the map
    map.on('load', function () {
        // Add geofence polygons
        Object.keys(geofences).forEach(zone => {
            map.addSource(zone, {
                "type": "geojson",
                "data": geofences[zone]
            });

            map.addLayer({
                "id": zone,
                "type": "fill",
                "source": zone,
                "layout": {},
                "paint": {
                    "fill-color": zone === "largeZone" ? "#3388ff" : zone === "CBD" ? "#33cc33" : "#ff9900",
                    "fill-opacity": 0.3
                }
            });

            // Add outline for each zone
            map.addLayer({
                "id": zone + "-outline",
                "type": "line",
                "source": zone,
                "layout": {},
                "paint": {
                    "line-color": zone === "largeZone" ? "#0066ff" : zone === "CBD" ? "#009900" : "#cc7a00",
                    "line-width": 2
                }
            });
        });
    });

    // Create a custom marker for the driver
    function createCustomMarker(markerImageUrl) {
        const markerEl = document.createElement('div');
        markerEl.style.backgroundImage = 'url("' + (markerImageUrl || '/resources/images/redbus.png') + '")';
        markerEl.style.width = '30px';
        markerEl.style.height = '30px';
        markerEl.style.backgroundSize = 'cover';
        markerEl.style.cursor = 'pointer';

        markerEl.addEventListener('click', () => {
            // Use the correct API endpoint based on your backend controller
            fetch('/Nganya/api/driverProfile/driverDetails')
                    .then(res => {
                        if (!res.ok)
                            throw new Error(res.statusText);
                        return res.json();
                    })
                    .then(profile => {
                        // Update modal with driver details from API
                        document.getElementById('modal-username').textContent = profile.username;
                        document.getElementById('modal-firstName').textContent = profile.firstName;
                        document.getElementById('modal-lastName').textContent = profile.lastName;
                        document.getElementById('modal-vehiclePlate').textContent = profile.vehiclePlate || 'Not assigned';
                        document.getElementById('modal-vehicleModel').textContent = profile.vehicleModel || 'Not assigned';

                        // Show the modal
                        PF('driverInfoDialog').show();
                    })
                    .catch(err => {
                        console.error('Error loading driver details:', err);
                        alert('Unable to load driver details. Please try again later.');
                    });
        });

        return markerEl;
    }

    // Check if a point is in any of the defined geofences
    function isInGeofence(lng, lat) {
        const point = turf.point([lng, lat]);
        return Object.values(geofences).some(zone =>
            turf.booleanPointInPolygon(point, zone.geometry)
        );
    }

    // Function to send geolocation data via WebSocket
    async function sendGeolocationData(position) {
        let driverProfile;
        try {
            const res = await fetch('/Nganya/api/driverProfile/driverDetails');
            if (!res.ok)
                throw new Error(res.statusText);
            const profile = await res.json();
            driverProfile = {
                username: profile.username,
                firstName: profile.firstName,
                lastName: profile.lastName,
                vehiclePlate: profile.vehiclePlate,
                vehicleModel: profile.vehicleModel
            };
        } catch (err) {
            console.error('Error loading driver details:', err);
            alert('Unable to load driver details. Please try again later.');
            return; // abort if we cannot get profile
        }

        const {longitude: lng, latitude: lat} = position.coords;
        const userData = {
            lat,
            lng,
            driverId: driverProfile.username,
            inZone: isInGeofence(lng, lat),
            driverProfile
        };

        if (websocket.readyState === WebSocket.OPEN) {
            websocket.send(JSON.stringify(userData));
        } else {
            websocket.addEventListener('open', () => {
                websocket.send(JSON.stringify(userData));
            }, {once: true});
        }
    }
    // Prompt for device geolocation and update the map accordingly
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function (position) {
            const userCoords = [position.coords.longitude, position.coords.latitude];

            // Center the map on the user's current location
            console.log("coordinates", userCoords[0], "latitude ", userCoords[1]);
            map.setCenter(userCoords);

            // Add a custom marker to indicate the user's location
            const customMarker = new mapboxgl.Marker(createCustomMarker(markerImageUrl))
                    .setLngLat(userCoords)
                    .addTo(map);

            // Send location data via WebSocket
            sendGeolocationData(position);

            // Set up continuous tracking
            navigator.geolocation.watchPosition(function (position) {
                const newCoords = [position.coords.longitude, position.coords.latitude];
                customMarker.setLngLat(newCoords);
                sendGeolocationData(position);
            }, function (error) {
                console.error("Error in tracking position: ", error);
            }, {
                enableHighAccuracy: true,
                maximumAge: 10000, // 10 seconds
                timeout: 15000      // 15 seconds
            });

        }
        , function (error) {
            console.error("Error obtaining location: ", error);
            alert("Unable to access your location. Please enable location services for this application.");
        });
    } else {
        console.error("Geolocation is not supported by this browser.");
        alert("Geolocation is not supported by your browser. Please use a modern browser with location services enabled.");
    }

    // Set up WebSocket event listeners
    websocket.addEventListener('open', function (event) {
        console.log('WebSocket connection established');
    });

    websocket.addEventListener('message', function (event) {
        console.log('Message from server:', event.data);
        // Handle incoming messages if needed
    });

    websocket.addEventListener('close', function (event) {
        console.log('WebSocket connection closed');
        // Implement reconnection logic
        setTimeout(() => {
            console.log('Attempting to reconnect...');
        }, 5000);
    });

    websocket.addEventListener('error', function (event) {
        console.error('WebSocket error:', event);
    });
};









// ---------- Admin-side Map ----------

// Admin-side map JavaScript (adminMap.js)
const initAdminMap = () => {
    // Set your Mapbox access token
    mapboxgl.accessToken = 'pk.eyJ1Ijoib2xhbCIsImEiOiJjbThidjM5aTgxcDNtMm1zNTh6NjRqeDE3In0.EIobbUYeWUFMarhuxGr_sg';

    // Initialize the map centered on a default location
    const map = new mapboxgl.Map({
        container: 'adminMap', // ID of the map container
        style: 'mapbox://styles/mapbox/streets-v11',
        center: [36.860235, -1.300294], // Default center (Nairobi)
        zoom: 12
    });

    // per-driver previous state
    const driverState = new Map();

    // Add navigation controls (zoom and rotation)
    map.addControl(new mapboxgl.NavigationControl());

    // Define geofences using GeoJSON
    const geofences = {
        "largeZone": {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                        [36.793850, -1.268661], [36.868210, -1.234116],
                        [36.939121, -1.323920], [36.863803, -1.358592],
                        [36.793850, -1.268661]
                    ]]
            }
        },
        "CBD": {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                        [36.814932, -1.283793], [36.834377, -1.278729],
                        [36.841615, -1.287849], [36.819990, -1.297579],
                        [36.814932, -1.283793]
                    ]]
            }
        },
        "StageEmbakasi": {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                        [36.892297, -1.315585], [36.903495, -1.315585],
                        [36.903495, -1.330043], [36.892297, -1.330043],
                        [36.892297, -1.315585]
                    ]]
            }
        }
    };

    // Create a custom marker for vehicles
    function createVehicleMarker(inZone = true, driverProfile = {}) {
        const markerEl = document.createElement('div');
        markerEl.className = 'vehicle-marker';

        // Default marker image or conditional styling based on in-zone status
        const markerImgSrc = inZone ? inZonecar : outZonecar;

        markerEl.style.backgroundImage = `url("${markerImgSrc}")`;
        markerEl.style.width = '30px';
        markerEl.style.height = '30px';
        markerEl.style.backgroundSize = 'cover';
        markerEl.style.cursor = 'pointer';

        // Add click event to show driver details dialog
        markerEl.addEventListener('click', () => {
            // Instead of making an API call, use the data we already have
            if (driverProfile) {
                document.getElementById('modal-username').textContent = driverProfile.username;
                document.getElementById('modal-firstName').textContent = driverProfile.firstName;
                document.getElementById('modal-lastName').textContent = driverProfile.lastName;
                document.getElementById('modal-vehiclePlate').textContent = driverProfile.vehiclePlate;
                document.getElementById('modal-vehicleModel').textContent = driverProfile.vehicleModel;
                console.log(driverProfile.username);
                // Show the modal using PrimeFaces dialog
                PF('driverInfoDialog').show();
            } else {
                console.error('No driver profile data available');
                alert('Driver information is not available');
            }
        });

        return markerEl;
    }

    // Add geofence layers to the map
    map.on('load', function () {
        // Add geofence polygons
        Object.keys(geofences).forEach(zone => {
            map.addSource(zone, {
                "type": "geojson",
                "data": geofences[zone]
            });

            map.addLayer({
                "id": zone,
                "type": "fill",
                "source": zone,
                "layout": {},
                "paint": {
                    "fill-color": zone === "largeZone" ? "#3388ff" : zone === "CBD" ? "#33cc33" : "#ff9900",
                    "fill-opacity": 0.3
                }
            });

            // Add outline for each zone
            map.addLayer({
                "id": zone + "-outline",
                "type": "line",
                "source": zone,
                "layout": {},
                "paint": {
                    "line-color": zone === "largeZone" ? "#0066ff" : zone === "CBD" ? "#009900" : "#cc7a00",
                    "line-width": 2
                }
            });
        });

        // Add highlighted roads
        map.addLayer({
            "id": "highlighted-roads",
            "type": "line",
            "source": {
                "type": "vector",
                "url": "mapbox://mapbox.mapbox-streets-v8"
            },
            "source-layer": "road",
            "filter": ["in", "name",
                "Jogoo Road", "Airport North Road",
                "Uhuru Highway", "Murang'a Road", "Lusaka Road",
                "Mombasa Road", "Haile Selassie Avenue", "Outer Ring Road", "Thika Road"
            ],
            "layout": {
                "line-join": "round",
                "line-cap": "round"
            },
            "paint": {
                "line-color": "#ff0000", // Highlight color (red)
                "line-width": 3
            }
        });
    });

    // Store vehicle markers
    let vehicleMarkers = new Map();

    // WebSocket connection to track vehicles
    const websocketProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = websocketProtocol + '//' + window.location.host + '/Nganya/tracking';
    let websocket = new WebSocket(wsUrl);

    websocket.onmessage = function (event) {
        const data = JSON.parse(event.data);
        updateVehiclePosition(data);
    };

    function updateVehiclePosition(vehicle) {
        const lngLat = [vehicle.lng, vehicle.lat];
        const point = turf.point(lngLat);

        // Check if vehicle is in any geofence
        vehicle.inZone = Object.values(geofences).some(zone =>
            turf.booleanPointInPolygon(point, zone.geometry)
        );

        if (!vehicleMarkers.has(vehicle.driverId)) {
            // Create a new marker using the custom marker function
            const marker = new mapboxgl.Marker(
                    createVehicleMarker(vehicle.inZone, vehicle.driverProfile)
                    ).setLngLat(lngLat).addTo(map);

            vehicleMarkers.set(vehicle.driverId, {
                marker: marker,
                driverProfile: vehicle.driverProfile

            });
        } else {
            // Update existing marker position and appearance
            const markerData = vehicleMarkers.get(vehicle.driverId);
            markerData.marker.setLngLat(lngLat);

            // Update driver profile data
            markerData.driverProfile = vehicle.driverProfile;

            // Optionally update marker appearance if in/out of zone status changed
            // This would require removing and recreating the marker
        }

        checkGeofence(vehicle);
    }

    // Function to check if a vehicle is inside specific geofences and trigger actions
    function checkGeofence(vehicle) {
        const point = turf.point([vehicle.lng, vehicle.lat]);
        const prev = driverState.get(vehicle.driverId) || {
            inLargeZone: false,
            inCBD: false,
            inEmbakasi: false
        };

        console.log(
                `Checking geofences for vehicle: ${vehicle.driverId}, Location:`,
                point.geometry.coordinates
                );

        // --- Large Zone entry/exit ---
        const nowLarge = turf.booleanPointInPolygon(point, geofences.largeZone.geometry);
        if (nowLarge !== prev.inLargeZone) {
            if (!nowLarge) {
                callMapController("triggerExit", vehicle.driverId);
                console.log(`⚠️ Vehicle ${vehicle.driverId} is outside the large zone`);
            } else {
                console.log(`✅ Vehicle ${vehicle.driverId} has entered the large zone`);
            }
        } else {
            console.log(
                    nowLarge
                    ? `✅ Vehicle ${vehicle.driverId} remains inside the large zone`
                    : `⚠️ Vehicle ${vehicle.driverId} remains outside the large zone`
                    );
        }

        // --- CBD (start trip) on entry only ---
        const nowCBD = turf.booleanPointInPolygon(point, geofences.CBD.geometry);
        if (nowCBD && !prev.inCBD) {
            callMapController("startTrip", vehicle.driverId);
            console.log(`🚕 Vehicle ${vehicle.driverId} has entered the CBD — Trip started`);
        } else if (!nowCBD && prev.inCBD) {
            console.log(`↩️ Vehicle ${vehicle.driverId} has exited the CBD`);
        } else {
            console.log(
                    nowCBD
                    ? `🚕 Vehicle ${vehicle.driverId} remains in the CBD`
                    : `🚗 Vehicle ${vehicle.driverId} is not in the CBD`
                    );
        }

        // --- StageEmbakasi (end trip) on entry only ---
        const nowEmbakasi = turf.booleanPointInPolygon(point, geofences.StageEmbakasi.geometry);
        if (nowEmbakasi && !prev.inEmbakasi) {
            callMapController("endTrip", vehicle.driverId);
            console.log(`🏁 Vehicle ${vehicle.driverId} has entered Embakasi — Trip ended`);
        } else if (!nowEmbakasi && prev.inEmbakasi) {
            console.log(`↩️ Vehicle ${vehicle.driverId} has exited Embakasi`);
        } else {
            console.log(
                    nowEmbakasi
                    ? `🏁 Vehicle ${vehicle.driverId} remains at Embakasi`
                    : `🚗 Vehicle ${vehicle.driverId} is not at Embakasi`
                    );
        }

        // save new state
        driverState.set(vehicle.driverId, {
            inLargeZone: nowLarge,
            inCBD: nowCBD,
            inEmbakasi: nowEmbakasi
        });
    }

    // Function to send event to mapController
    function callMapController(action, driverId) {
        fetch(`/Nganya/api/mapController/${action}?driverId=${driverId}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        })
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    return response.json();
                })
                .then(data => console.log("Server response:", data))
                .catch(error => console.error("Error calling controller:", error));
    }

    // Reconnect WebSocket if disconnected
    function reconnect() {
        setTimeout(() => {
            websocket = new WebSocket(wsUrl);
            websocket.onopen = () => console.log('WebSocket reconnected');
            websocket.onmessage = event => {
                const data = JSON.parse(event.data);
                updateVehiclePosition(data);
            };
            websocket.onclose = reconnect;
        }, 5000);
    }

    websocket.onclose = reconnect;
};


document.addEventListener('DOMContentLoaded', function () {
    if (document.getElementById('driverMap')) {
        initDriverMap();
    } else if (document.getElementById('adminMap')) {
        initAdminMap();
    }
});