package com.ignium.nganya.weather;

import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import org.json.JSONArray;
import org.json.JSONObject;
import org.primefaces.model.charts.ChartData;
import org.primefaces.model.charts.line.LineChartDataSet;
import org.primefaces.model.charts.line.LineChartModel;
import org.primefaces.model.charts.line.LineChartOptions;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Named
@RequestScoped
public class WeatherForecast {

    @Inject
    private WeatherService weatherService;

    private LineChartModel weatherChart;

    @PostConstruct
    public void init() {
        weatherChart = new LineChartModel();
        loadWeatherData();
    }

    private void loadWeatherData() {
        try {
            // Request a 7-day forecast for Nairobi
            JSONObject forecastData = weatherService.getWeatherForecast("Nairobi");
            // Access the "daily" object and then its "data" array.
            JSONArray forecastDays = forecastData.getJSONObject("daily").getJSONArray("data");

            List<Object> labels = new ArrayList<>();
            List<Number> temperatures = new ArrayList<>();
            List<Number> precipitation = new ArrayList<>();

            // Date formatter (though the API provides a date string already)
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

            for (int i = 0; i < forecastDays.length(); i++) {
                JSONObject day = forecastDays.getJSONObject(i);

                // Extract the date from the "day" field.
                String dateStr = day.optString("day", null);
                if (dateStr == null) {
                    // Fallback: if "day" is missing, try "dt" (if provided as Unix timestamp)
                    long dt = day.getLong("dt") * 1000L;
                    Date date = new Date(dt);
                    dateStr = sdf.format(date);
                }
                labels.add(dateStr);

                // Extract temperature from "all_day"
                JSONObject allDay = day.getJSONObject("all_day");
                double temp = allDay.getDouble("temperature");
                temperatures.add(temp);

                // Extract precipitation from "all_day.precipitation"
                double precip = 0.0;
                if (allDay.has("precipitation")) {
                    JSONObject precipObj = allDay.getJSONObject("precipitation");
                    precip = precipObj.optDouble("total", 0.0);
                }
                precipitation.add(precip);
            }

            // Build the chart datasets.
            ChartData data = new ChartData();
            List<Object> tempData = new ArrayList<>(temperatures);
            List<Object> precipData = new ArrayList<>(precipitation);

            // Temperature dataset
            LineChartDataSet tempDataSet = new LineChartDataSet();
            tempDataSet.setData(tempData);
            tempDataSet.setLabel("Avg Temperature (°C)");
            tempDataSet.setBorderColor("rgba(255, 99, 132, 1)");
            tempDataSet.setBackgroundColor("rgba(255, 99, 132, 0.2)");
            tempDataSet.setFill(false);

            // Precipitation dataset
            LineChartDataSet precipDataSet = new LineChartDataSet();
            precipDataSet.setData(precipData);
            precipDataSet.setLabel("Total Precipitation (mm)");
            precipDataSet.setBorderColor("rgba(54, 162, 235, 1)");
            precipDataSet.setBackgroundColor("rgba(54, 162, 235, 0.2)");
            precipDataSet.setFill(false);

            data.setLabels(labels);
            data.addChartDataSet(tempDataSet);
            data.addChartDataSet(precipDataSet);

            LineChartOptions options = new LineChartOptions();
            weatherChart.setOptions(options);
            weatherChart.setData(data);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public LineChartModel getWeatherChart() {
        return weatherChart;
    }
}
