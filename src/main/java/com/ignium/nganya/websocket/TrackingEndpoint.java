package com.ignium.nganya.websocket;

import com.ignium.nganya.MessageUtility;
import com.ignium.nganya.analytics.AnalyticsDao;
import com.ignium.nganya.driver.DriverDao;
import jakarta.inject.Inject;
import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import com.google.gson.Gson;

@ServerEndpoint(value = "/tracking",
        configurator = SecurityConfigurator.class)
public class TrackingEndpoint {

    private static final Logger logger = Logger.getLogger(TrackingEndpoint.class.getName());
    private static final Set<Session> sessions = ConcurrentHashMap.newKeySet();

    // Store driver sessions with driverId as key
    private static final Map<String, Session> driverSessions
            = new ConcurrentHashMap<>();

    // Store admin sessions
    private static final Set<Session> adminSessions
            = Collections.synchronizedSet(new HashSet<>());

  

    @Inject
    private DriverDao driverDao;
    
   @Inject private TripService tripService;

    // Session registration method called from DriverController
    public static void registerDriverSession(String driverId, Session session) {
        driverSessions.put(driverId, session);
    }

    @OnOpen
    public void onOpen(Session session) {
        sessions.add(session);
        Map<String, Object> props = session.getUserProperties();
        String username = (String) props.get("username");
        String role = (String) props.get("role");

        if (username != null && role != null) {
            if ("DRIVER".equals(role)) {
                driverSessions.put(username, session);
                System.out.println("Driver session loaded for: " + username);
            } else if ("ADMIN".equals(role)) {
                adminSessions.add(session);
                System.out.println("Admin session loaded for: " + username);
            }
        } else {
            System.out.println("Username or role not found in session during onOpen.");
        }
    }

    @OnMessage
    public void onMessage(Session session, String message) {
        try {
            LocationUpdate update = new Gson().fromJson(message, LocationUpdate.class);
            logger.info(update.toString());
            
            // Record location update
            tripService.recordLocation(update);
            
            // Broadcast only to admin sessions
            broadcastToAdmins(message);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error processing location update", e);
            // Try to send error back to client if possible
            try {
                session.getBasicRemote().sendText("Error processing location update: " + e.getMessage());
            } catch (IOException ex) {
                logger.log(Level.SEVERE, "Error sending error message to client", ex);
            }
        }
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session);
        String username = (String) session.getUserProperties().get("username");
        String role = (String) session.getUserProperties().get("role");
        if (username != null && role != null) {
            if ("DRIVER".equals(role)) {
                driverSessions.remove(username);
                System.out.println("Driver session closed for: " + username);
            } else if ("ADMIN".equals(role)) {
                adminSessions.remove(session);
                System.out.println("Admin session closed for: " + username);
            }
        } else {
            System.out.println("Username or role not found during onClose.");
        }
    }

    private void broadcastToAdmins(String message) {
        adminSessions.forEach(s -> {
            if (s.isOpen()) {
                s.getAsyncRemote().sendText(message);
                System.out.println("Broadcast to admins");
            }
        });
    }
}
