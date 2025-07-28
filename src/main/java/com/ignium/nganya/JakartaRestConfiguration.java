package com.ignium.nganya;

import com.ignium.nganya.controller.DriverProfile;
import com.ignium.nganya.websocket.MapController;
import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;
import java.util.HashSet;
import java.util.Set;

/**
 * Configures Jakarta RESTful Web Services for the application.
 * @author Juneau
 */
@ApplicationPath("/api")
public class JakartaRestConfiguration extends Application {
    @Override
    public Set<Class<?>> getClasses() {
        Set<Class<?>> classes = new HashSet<>();
        classes.add(MapController.class);
        classes.add(DriverProfile.class);
        return classes;
    }
    
}
