package com.ignium.nganya.route.models;

import jakarta.json.bind.Jsonb;
import jakarta.json.bind.JsonbBuilder;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.HashMap;

public class MapOfMetrics implements ParameterizedType {

    @Override
    public Type[] getActualTypeArguments() {
        // Specify the actual type arguments for the HashMap, which is String and Object
        return new Type[] { String.class, Object.class };
    }

    @Override
    public Type getRawType() {
        // Specify the raw type as HashMap
        return HashMap.class;
    }

    @Override
    public Type getOwnerType() {
        return null;
    }

    // Method to deserialize JSON string into a HashMap<String, Object>
    public static HashMap<String, Object> deserializeMetrics(String jsonData) {
        Jsonb jsonb = JsonbBuilder.create();
        Type mapType = new MapOfMetrics();
        return jsonb.fromJson(jsonData, mapType);
    }
}
