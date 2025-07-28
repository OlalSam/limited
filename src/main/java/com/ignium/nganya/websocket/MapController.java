package com.ignium.nganya.websocket;

import com.ignium.nganya.schedule.NotificationService;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.time.LocalTime;

@Path("/mapController")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class MapController {

    @Inject
    private NotificationService notificationService;
    
    @Inject
    private TripService tripService;

    @POST
    @Path("/{action}")
    public Response handleAction(
            @PathParam("action") String action, 
            @QueryParam("driverId") String driverId,
            @QueryParam("lat") Double lat,
            @QueryParam("lng") Double lng) {
            
        if (driverId == null || driverId.isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Missing driverId\"}")
                    .build();
        }

        switch (action) {
            case "triggerExit":
                return handleTriggerExit(driverId);
            case "startTrip":
                return handleStartTrip(driverId, lat, lng);
            case "endTrip":
                return handleEndTrip(driverId, lat, lng);
            default:
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\": \"Invalid action\"}")
                        .build();
        }
    }

    private Response handleTriggerExit(String driverId) {
        System.out.println("Vehicle exited geofence: " + driverId);
        notificationService.sendZoneViolationAlert(driverId, LocalTime.now());
        return Response.ok("{\"message\": \"Exit triggered for driver " + driverId + "\"}").build();
    }

    private Response handleStartTrip(String driverId, Double lat, Double lng) {
        if (lat == null || lng == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Missing location data\"}")
                    .build();
        }
        
        System.out.println("Trip started for driver: " + driverId + " at location: " + lat + "," + lng);
        tripService.startTrip(driverId, lat, lng);
        return Response.ok("{\"message\": \"Trip started for driver " + driverId + "\"}").build();
    }

    private Response handleEndTrip(String driverId, Double lat, Double lng) {
        if (lat == null || lng == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Missing location data\"}")
                    .build();
        }
        
        System.out.println("Trip ended for driver: " + driverId + " at location: " + lat + "," + lng);
        tripService.endTrip(driverId, lat, lng);
        return Response.ok("{\"message\": \"Trip ended for driver " + driverId + "\"}").build();
    }
}
