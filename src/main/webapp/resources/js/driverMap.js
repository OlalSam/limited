// ---------- Driver-side Map ----------

// Driver-side map JavaScript (driverMap.js)
const initDriverMap = () => {
    // Set Mapbox access token
    mapboxgl.accessToken = 'pk.eyJ1Ijoib2xhbCIsImEiOiJjbThidjM5aTgxcDNtMm1zNTh6NjRqeDE3In0.EIobbUYeWUFMarhuxGr_sg';

    // Initialize the Mapbox map centered on a default location
    const map = new mapboxgl.Map({
        container: 'driverMap', // Container ID
        style: 'mapbox://styles/mapbox/streets-v11',
        center: [36.860235, -1.300294], // Default coordinates (Nairobi)
        zoom: 12 // Starting zoom level
    });

    // Add navigation controls (zoom and rotation)
    map.addControl(new mapboxgl.NavigationControl());

    // WebSocket setup
    const websocketProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = websocketProtocol + '//' + window.location.host + '/Nganya/tracking';
    let websocket = new WebSocket(wsUrl);

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

    // Cache for driver profile to avoid repeated fetches

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

    // Function to fetch driver profile data
    async function fetchDriverProfile() {
        try {
            const res = await fetch('/Nganya/api/driverProfile/driverDetails');
            if (!res.ok) {
                throw new Error(`HTTP error! Status: ${res.status}`);
            }
            const profile = await res.json();

            // Log the received data for debugging
            console.log("Driver profile loaded:", profile);

            return {
                username: profile.username,
                firstName: profile.firstName,
                lastName: profile.lastName,
                vehiclePlate: profile.vehiclePlate || 'Not assigned',
                vehicleModel: profile.vehicleModel || 'Not assigned'
            };
        } catch (err) {
            console.error('Error loading driver details:', err);
            return null;
        }
    }

    // Create a custom marker for the driver
    function createCustomMarker(markerImageUrl) {
        const markerEl = document.createElement('div');
        markerEl.style.backgroundImage = 'url("' + (markerImageUrl || '/resources/images/redbus.png') + '")';
        markerEl.style.width = '30px';
        markerEl.style.height = '30px';
        markerEl.style.backgroundSize = 'cover';
        markerEl.style.cursor = 'pointer';

        markerEl.addEventListener('click', async () => {
            let cachedDriverProfile = {};
            cachedDriverProfile = await fetchDriverProfile();
            if (!cachedDriverProfile) {
                console.error('No driver profile data available');
                alert('Driver information is not available');
                return;

            }


            // Update modal with driver details
            document.getElementById('modal-username').textContent = cachedDriverProfile.username;
            document.getElementById('modal-firstName').textContent = cachedDriverProfile.firstName;
            document.getElementById('modal-lastName').textContent = cachedDriverProfile.lastName;
            document.getElementById('modal-vehiclePlate').textContent = cachedDriverProfile.vehiclePlate;
            document.getElementById('modal-vehicleModel').textContent = cachedDriverProfile.vehicleModel;

            // Show the modal
            PF('driverInfoDialog').show();

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
        // Get or fetch driver profile data
        let cachedDriverProfile = {};
        if (!cachedDriverProfile || Object.keys(cachedDriverProfile).length === 0) {
            cachedDriverProfile = await fetchDriverProfile();
            if (!cachedDriverProfile) {
                console.error('Failed to get driver profile for location update');
                return; // abort if we cannot get profile
            }
        }

        const {longitude: lng, latitude: lat} = position.coords;
        const inZone = isInGeofence(lng, lat);

        const userData = {
            lat,
            lng,
            driverId: cachedDriverProfile.username,
            inZone,
            driverProfile: cachedDriverProfile
        };

        console.log("Sending location data:", userData);

        if (websocket.readyState === WebSocket.OPEN) {
            websocket.send(JSON.stringify(userData));
        } else if (websocket.readyState === WebSocket.CONNECTING) {
            // Wait for connection to open then send
            websocket.addEventListener('open', () => {
                websocket.send(JSON.stringify(userData));
            }, {once: true});
        } else {
            // Reconnect if connection is closed or closing
            console.log("WebSocket not open. Current state:", websocket.readyState);
            reconnectWebSocket();
        }
    }

    // Reconnect WebSocket function
    function reconnectWebSocket() {
        console.log("Reconnecting WebSocket...");
        websocket = new WebSocket(wsUrl);

        websocket.addEventListener('open', function (event) {
            console.log('WebSocket connection re-established');
        });

        websocket.addEventListener('message', function (event) {
            console.log('Message from server:', event.data);
        });

        websocket.addEventListener('close', function (event) {
            console.log('WebSocket connection closed');
            setTimeout(reconnectWebSocket, 5000);
        });

        websocket.addEventListener('error', function (event) {
            console.error('WebSocket error:', event);
        });
    }

    // Set up geolocation watching with throttling
    let lastSentTimestamp = 0;
    const THROTTLE_INTERVAL = 5 * 1000; // 20 seconds

    // --- Add geofence event detection and reporting ---
    let lastGeofenceState = {
        inLargeZone: null,
        inCBD: null,
        inEmbakasi: null
    };

    function checkGeofenceAndReport(lng, lat, driverId) {
        const point = turf.point([lng, lat]);
        const isInLargeZone = turf.booleanPointInPolygon(point, geofences.largeZone.geometry);
        const isInCBD = turf.booleanPointInPolygon(point, geofences.CBD.geometry);
        const isInEmbakasi = turf.booleanPointInPolygon(point, geofences.StageEmbakasi.geometry);

        console.log(`Coords: [${lng}, ${lat}] | inLargeZone: ${isInLargeZone}, inCBD: ${isInCBD}, inEmbakasi: ${isInEmbakasi}`);
        console.log('Previous state:', lastGeofenceState);

        // On first run, just set the state
        if (lastGeofenceState.inLargeZone === null) {
            lastGeofenceState.inLargeZone = isInLargeZone;
            lastGeofenceState.inCBD = isInCBD;
            lastGeofenceState.inEmbakasi = isInEmbakasi;
            return;
        }

        // Large Zone exit
        if (lastGeofenceState.inLargeZone === true && !isInLargeZone) {
            callMapController("triggerExit", driverId, lat, lng);
            console.log(`⚠️ Driver ${driverId} exited the large zone`);
        }
        // CBD entry
        if (lastGeofenceState.inCBD === false && isInCBD) {
            callMapController("startTrip", driverId, lat, lng);
            console.log(`🚕 Driver ${driverId} entered the CBD - Trip started`);
        }
        // Embakasi entry
        if (lastGeofenceState.inEmbakasi === false && isInEmbakasi) {
            callMapController("endTrip", driverId, lat, lng);
            console.log(`🏁 Driver ${driverId} entered Embakasi - Trip ended`);
        }

        // Update last state
        lastGeofenceState.inLargeZone = isInLargeZone;
        lastGeofenceState.inCBD = isInCBD;
        lastGeofenceState.inEmbakasi = isInEmbakasi;
    }

    // Patch the watchCallback to include geofence event reporting
    function watchCallback(position) {
        const now = Date.now();
        if (now - lastSentTimestamp >= THROTTLE_INTERVAL) {
            sendGeolocationData(position);
            lastSentTimestamp = now;
        }
        // Geofence event reporting
        if (cachedDriverProfile) {
            const {longitude: lng, latitude: lat} = position.coords;
            checkGeofenceAndReport(lng, lat, cachedDriverProfile.username);
        }
    }

    // Prompt for device geolocation and update the map accordingly
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(async function (position) {
            const userCoords = [position.coords.longitude, position.coords.latitude];

            // Center the map on the user's current location
            console.log("Current coordinates - Longitude:", userCoords[0], "Latitude:", userCoords[1]);
            map.setCenter(userCoords);

            // Get marker image URL - ensure this variable is defined or use default
            const markerImageUrl = window.markerImageUrl || '/resources/images/redbus.png';

            // Add a custom marker to indicate the user's location
            const customMarker = new mapboxgl.Marker(createCustomMarker(markerImageUrl))
                    .setLngLat(userCoords)
                    .addTo(map);

            // Preload driver profile
            cachedDriverProfile = await fetchDriverProfile();

            // Send location data via WebSocket
            sendGeolocationData(position);
            lastSentTimestamp = Date.now();

            // Set up continuous tracking
            navigator.geolocation.watchPosition(
                    watchCallback,
                    function (error) {
                        console.error("Error in tracking position:", error);
                    },
                    {
                        enableHighAccuracy: true,
                        maximumAge: 10000, // 10 seconds
                        timeout: 60000      // 15 seconds
                    }
            );
        }, function (error) {
            console.error("Error obtaining location:", error);
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
        setTimeout(reconnectWebSocket, 5000);
    });

    websocket.addEventListener('error', function (event) {
        console.error('WebSocket error:', event);
    });
};

// ---------- Admin-side Map ----------

// Admin-side map JavaScript (adminMap.js)
const initAdminMap = () => {
    // Set Mapbox access token
    mapboxgl.accessToken = 'pk.eyJ1Ijoib2xhbCIsImEiOiJjbThidjM5aTgxcDNtMm1zNTh6NjRqeDE3In0.EIobbUYeWUFMarhuxGr_sg';

    // Initialize the map centered on a default location
    const map = new mapboxgl.Map({
        container: 'adminMap', // ID of the map container
        style: 'mapbox://styles/mapbox/streets-v11',
        center: [36.860235, -1.300294], // Default center (Nairobi)
        zoom: 12
    });

    // Per-driver previous state - used to track state changes
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

    // Get image paths - make sure these variables are defined in your HTML
    const inZonecar = window.inZonecar || '/resources/images/greenbus.png';
    const outZonecar = window.outZonecar || '/resources/images/redbus.png';

    // Create a custom marker for vehicles
    async function createVehicleMarker(inZone = true, driverProfile = {}, username) {
        const markerEl = document.createElement('div');
        markerEl.className = 'vehicle-marker';

        // Choose marker image based on zone
        const markerImgSrc = inZone ? inZonecar : outZonecar;
        markerEl.style.cssText = `
            background-image: url("${markerImgSrc}");
            width: 30px;
            height: 30px;
            background-size: cover;
            cursor: pointer;
        `;

        // Click handler must be async
        markerEl.addEventListener('click', async () => {
            let profile = driverProfile;

            // If we weren't given a profile, fetch it now
            if (!profile || Object.keys(profile).length === 0) {
                profile = await fetchProfile(username);
                if (!profile) {
                    console.error('No driver profile data available');
                    alert('Driver information is not available');
                    return;  // bail out
                }
            }

            // Populate and show the modal
            document.getElementById('modal-username').textContent = profile.username;
            document.getElementById('modal-firstName').textContent = profile.firstName;
            document.getElementById('modal-lastName').textContent = profile.lastName;
            document.getElementById('modal-vehiclePlate').textContent = profile.vehiclePlate;
            document.getElementById('modal-vehicleModel').textContent = profile.vehicleModel;

            console.log("Showing driver info:", profile);
            PF('driverInfoDialog').show();
        });

        return markerEl;
    }

    // Function to fetch driver profile data
    async function fetchProfile(username) {
        try {
            const res = await fetch(`/Nganya/api/driverProfile/driverDetails/${username}`);
            if (!res.ok) {
                throw new Error(`HTTP error! Status: ${res.status}`);
            }
            const profile = await res.json();
            console.log("Driver profile loaded:", profile);
            return {
                username: profile.username,
                firstName: profile.firstName,
                lastName: profile.lastName,
                vehiclePlate: profile.vehiclePlate || 'Not assigned',
                vehicleModel: profile.vehicleModel || 'Not assigned'
            };
        } catch (err) {
            console.error('Error loading driver details:', err);
            return null;
        }
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
        try {
            const data = JSON.parse(event.data);
            console.log("Received vehicle data:", data);
            updateVehiclePosition(data);
        } catch (error) {
            console.error("Error processing WebSocket message:", error);
        }
    };

    function updateVehiclePosition(vehicle) {
        if (!vehicle || !vehicle.driverId) {
            console.error("Invalid vehicle data received:", vehicle);
            return;
        }

        const lngLat = [vehicle.lng, vehicle.lat];
        const point = turf.point(lngLat);

        // Check if vehicle is in any geofence
        vehicle.inZone = Object.values(geofences).some(zone =>
            turf.booleanPointInPolygon(point, zone.geometry)
        );

        // Store previous state for comparison
        const previousState = driverState.get(vehicle.driverId) || {};
        driverState.set(vehicle.driverId, {
            inZone: vehicle.inZone,
            lat: vehicle.lat,
            lng: vehicle.lng,
            lastUpdate: new Date()
        });

        if (!vehicleMarkers.has(vehicle.driverId)) {
            console.log(`Creating new marker for driver ${vehicle.driverId}`);

            // Create and add the marker
            createVehicleMarker(vehicle.inZone, vehicle.driverProfile, vehicle.driverId)
                    .then(markerEl => {
                        const marker = new mapboxgl.Marker(markerEl)
                                .setLngLat(lngLat)
                                .addTo(map);

                        vehicleMarkers.set(vehicle.driverId, {
                            marker: marker,
                            driverProfile: vehicle.driverProfile
                        });
                    })
                    .catch(err => {
                        console.error('Failed to create marker element:', err);
                    });
        } else {
            // Update existing marker position
            const markerData = vehicleMarkers.get(vehicle.driverId);
            markerData.marker.setLngLat(lngLat);

            // Update driver profile data
            markerData.driverProfile = vehicle.driverProfile;

            // Check if in/out of zone status changed - update marker appearance if needed
            if (previousState.inZone !== vehicle.inZone) {
                console.log(`Vehicle ${vehicle.driverId} zone status changed: ${vehicle.inZone ? 'entering' : 'exiting'} zone`);

                // Remove old marker
                markerData.marker.remove();

                // Create new marker with updated appearance
                createVehicleMarker(vehicle.inZone, vehicle.driverProfile, vehicle.driverId)
                        .then(newMarkerEl => {
                            const newMarker = new mapboxgl.Marker(newMarkerEl)
                                    .setLngLat(lngLat)
                                    .addTo(map);

                            vehicleMarkers.set(vehicle.driverId, {
                                marker: newMarker,
                                driverProfile: vehicle.driverProfile
                            });
                        })
                        .catch(err => {
                            console.error('Failed to create updated marker element:', err);
                        });
            }
        }

        checkGeofence(vehicle);
    }

    // Function to check if a vehicle is inside specific geofences and trigger actions
    function checkGeofence(vehicle) {
        const point = turf.point([vehicle.lng, vehicle.lat]);
        const prev = driverState.get(vehicle.driverId) || {};

        // To avoid repeated triggers, we'll check for state changes
        const wasInLargeZone = prev.wasInLargeZone !== undefined ? prev.wasInLargeZone : true;
        const wasInCBD = prev.wasInCBD !== undefined ? prev.wasInCBD : false;
        const wasInEmbakasi = prev.wasInEmbakasi !== undefined ? prev.wasInEmbakasi : false;

        // Current states
        const isInLargeZone = turf.booleanPointInPolygon(point, geofences.largeZone.geometry);
        const isInCBD = turf.booleanPointInPolygon(point, geofences.CBD.geometry);
        const isInEmbakasi = turf.booleanPointInPolygon(point, geofences.StageEmbakasi.geometry);

        // Update state with current values for next comparison
        driverState.set(vehicle.driverId, {
            ...prev,
            wasInLargeZone: isInLargeZone,
            wasInCBD: isInCBD,
            wasInEmbakasi: isInEmbakasi
        });

        // Check for state changes

        // If vehicle just left large zone
        if (wasInLargeZone && !isInLargeZone) {
            callMapController("triggerExit", vehicle.driverId, vehicle.lat, vehicle.lng);
            console.log(`⚠️ Vehicle ${vehicle.driverId} has exited the large zone`);
        }

        // If vehicle just entered CBD
        if (!wasInCBD && isInCBD) {
            callMapController("startTrip", vehicle.driverId, vehicle.lat, vehicle.lng);
            console.log(`🚕 Vehicle ${vehicle.driverId} has entered the CBD - Trip started`);
        }

        // If vehicle just entered Embakasi stage
        if (!wasInEmbakasi && isInEmbakasi) {
            callMapController("endTrip", vehicle.driverId, vehicle.lat, vehicle.lng);
            console.log(`🏁 Vehicle ${vehicle.driverId} has arrived at Embakasi stage - Trip ended`);
        }
    }

    // Function to send event to mapController
    function callMapController(action, driverId, lat, lng) {
        fetch(`/Nganya/api/mapController/${action}?driverId=${driverId}&lat=${lat}&lng=${lng}`, {
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
        console.log("WebSocket disconnected. Attempting to reconnect...");
        setTimeout(() => {
            websocket = new WebSocket(wsUrl);

            websocket.onopen = () => {
                console.log('WebSocket reconnected');
            };

            websocket.onmessage = event => {
                try {
                    const data = JSON.parse(event.data);
                    updateVehiclePosition(data);
                } catch (error) {
                    console.error("Error processing WebSocket message:", error);
                }
            };

            websocket.onclose = reconnect;

            websocket.onerror = error => {
                console.error("WebSocket error:", error);
            };

        }, 5000);
    }

    websocket.onclose = reconnect;

    websocket.onerror = function (error) {
        console.error("WebSocket error:", error);
    };

    console.log("Admin map initialized");
};

// Initialize the appropriate map based on which container is present
document.addEventListener('DOMContentLoaded', function () {
    if (document.getElementById('driverMap')) {
        console.log("Initializing driver map");
        initDriverMap();
    } else if (document.getElementById('adminMap')) {
        console.log("Initializing admin map");
        initAdminMap();
    } else {
        console.warn("No map container found on page");
    }
});