package com.ignium.nganya.weather;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.MediaType;
import org.json.JSONObject;
import org.json.JSONException;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@ApplicationScoped
public class WeatherService {

    private static final String API_KEY = "xcsl58jjpnpepqi3r3s5dtpitgg15180i7f32ukv";
    // New API endpoint from Meteosource (free model)
    private static final String BASE_URL = "https://www.meteosource.com/api/v1/free/point";

    // Cache responses for 10 minutes
    private final Map<String, CachedWeather> cache = new HashMap<>();

    /**
     * Fetch the weather forecast for a given place using the Meteosource free
     * API.
     *
     * @param placeId the location identifier (e.g., "Nairobi")
     * @return a JSONObject representing the weather forecast data.
     */
    public JSONObject getWeatherForecast(String placeId) {
        JSONObject jsonData = new JSONObject();
        try {
            String cacheKey = placeId;
            CachedWeather cached = cache.get(cacheKey);

            // Return cached data if it's less than 10 minutes old
            if (cached != null && Instant.now().isBefore(cached.expiry)) {
                return cached.data;
            }

            // Create a new REST client and build the target URL with updated query parameters.
            // Note: We request current, hourly, and daily forecast data.
            Client client = ClientBuilder.newClient();
            WebTarget target = client.target(BASE_URL)
                    .queryParam("place_id", placeId)
                    .queryParam("sections", "current,hourly,daily")
                    .queryParam("language", "en")
                    .queryParam("units", "auto")
                    .queryParam("key", API_KEY);

            String response = target.request(MediaType.APPLICATION_JSON).get(String.class);
            jsonData = new JSONObject(response);

            // Cache the response for 10 minutes
            cache.put(cacheKey, new CachedWeather(jsonData, Instant.now().plusSeconds(600)));
            return jsonData;
        } catch (JSONException ex) {
            Logger.getLogger(WeatherService.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    private static class CachedWeather {

        JSONObject data;
        Instant expiry;

        CachedWeather(JSONObject data, Instant expiry) {
            this.data = data;
            this.expiry = expiry;
        }
    }
}
