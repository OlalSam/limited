import requests
import json
from datetime import datetime, timedelta
import time
import os
import random

class NairobiDataCollector:
    def __init__(self):
        # Create data directories if they don't exist
        self.data_dir = "nairobi_data"
        os.makedirs(os.path.join(self.data_dir, "weather"), exist_ok=True)
        os.makedirs(os.path.join(self.data_dir, "traffic"), exist_ok=True)
    
    def get_weekly_weather_forecast(self):
        """
        Get 7-day weather forecast for Nairobi using a weather API that doesn't require authentication
        """
        print("Fetching weekly weather forecast for Nairobi...")
        
        # Using weatherapi.com with a free API key (easier to get a working key)
        # Sign up for a free key at https://www.weatherapi.com/
        api_key = "c75e55dcbddb476c93b90256251603"  # Replace with your actual key
        
        # Alternative: Use the MetaWeather API (no key required)
        url = "https://api.open-meteo.com/v1/forecast?latitude=-1.29&longitude=36.82&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,weather_code&timezone=Africa%2FNairobi"
        
        try:
            response = requests.get(url)
            response.raise_for_status()
            
            # Process the data
            weather_data = response.json()
            
            # Save to JSON file with timestamp
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = os.path.join(self.data_dir, "weather", f"nairobi_forecast_{timestamp}.json")
            
            with open(filename, 'w') as f:
                json.dump(weather_data, f, indent=4)
                
            print(f"Weather forecast saved to {filename}")
            return weather_data
            
        except requests.exceptions.RequestException as e:
            print(f"Error fetching weather data: {e}")
            
            # If API fails, generate dummy data as fallback
            print("Generating simulated weather data as fallback...")
            weather_data = self._generate_simulated_weather_data()
            
            # Save simulated data
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = os.path.join(self.data_dir, "weather", f"nairobi_forecast_simulated_{timestamp}.json")
            
            with open(filename, 'w') as f:
                json.dump(weather_data, f, indent=4)
                
            print(f"Simulated weather forecast saved to {filename}")
            return weather_data
    
    def _generate_simulated_weather_data(self):
        """Generate simulated weather data for Nairobi for 7 days"""
        today = datetime.now()
        daily_data = []
        
        weather_codes = [0, 1, 2, 3, 45, 51, 53, 55, 61, 63, 65, 80, 81, 82]  # WMO weather codes
        
        for i in range(7):
            day = today + timedelta(days=i)
            
            # Nairobi temperatures typically range from 12-26°C
            min_temp = round(random.uniform(12, 18), 1)
            max_temp = round(random.uniform(19, 27), 1)
            
            # Randomly determine if it's rainy season
            rainy_season = random.random() > 0.5
            
            rain_amount = 0
            if rainy_season:
                rain_probability = random.random()
                if rain_probability > 0.4:  # 60% chance of rain in rainy season
                    rain_amount = round(random.uniform(0.5, 20), 1)
            
            daily_data.append({
                "date": day.strftime("%Y-%m-%d"),
                "temperature_min": min_temp,
                "temperature_max": max_temp,
                "precipitation": rain_amount,
                "weather_code": random.choice(weather_codes)
            })
        
        return {
            "latitude": -1.29,
            "longitude": 36.82,
            "timezone": "Africa/Nairobi",
            "elevation": 1795,
            "daily": {
                "time": [d["date"] for d in daily_data],
                "temperature_2m_min": [d["temperature_min"] for d in daily_data],
                "temperature_2m_max": [d["temperature_max"] for d in daily_data],
                "precipitation_sum": [d["precipitation"] for d in daily_data],
                "rain_sum": [d["precipitation"] for d in daily_data],
                "weather_code": [d["weather_code"] for d in daily_data]
            }
        }
    
    def get_traffic_history(self, road_list, days_back=30):
        """
        Generate simulated traffic data for specified roads in Nairobi
        since live traffic API access has issues
        
        Args:
            road_list: List of dictionaries with road info
            days_back: Number of days to look back
        """
        print(f"Generating traffic history for {len(road_list)} roads...")
        
        # Calculate date range
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days_back)
        
        all_traffic_data = {}
        
        for road in road_list:
            road_name = road["name"]
            print(f"Processing data for {road_name}...")
            
            # Generate simulated traffic data
            traffic_data = self._generate_simulated_traffic_data(road, start_date, end_date)
            all_traffic_data[road_name] = traffic_data
            
            # Save individual road data
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = os.path.join(self.data_dir, "traffic", f"{road_name.replace(' ', '_').lower()}_{timestamp}.json")
            
            with open(filename, 'w') as f:
                json.dump(traffic_data, f, indent=4)
                
            print(f"Traffic data for {road_name} saved to {filename}")
        
        # Save combined data
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        combined_filename = os.path.join(self.data_dir, "traffic", f"all_roads_traffic_{timestamp}.json")
        
        with open(combined_filename, 'w') as f:
            json.dump(all_traffic_data, f, indent=4)
            
        print(f"Combined traffic data saved to {combined_filename}")
        return all_traffic_data
    
    def _generate_simulated_traffic_data(self, road, start_date, end_date):
        """Generate realistic traffic data for a road over a period"""
        road_name = road["name"]
        traffic_data = {
            "roadName": road_name,
            "startCoordinates": {"latitude": road["start_lat"], "longitude": road["start_lon"]},
            "endCoordinates": {"latitude": road["end_lat"], "longitude": road["end_lon"]},
            "periodStart": start_date.strftime("%Y-%m-%dT00:00:00Z"),
            "periodEnd": end_date.strftime("%Y-%m-%dT23:59:59Z"),
            "data": []
        }
        
        # Generate data for each day
        current_date = start_date
        while current_date <= end_date:
            # Generate data for different times of day
            for hour in [7, 8, 9, 12, 13, 17, 18, 19]:
                is_weekday = current_date.weekday() < 5  # Monday to Friday
                
                # Set congestion levels based on typical traffic patterns
                if is_weekday:
                    if hour in [7, 8, 9]:  # Morning rush
                        congestion = random.uniform(0.7, 0.95)
                    elif hour in [17, 18, 19]:  # Evening rush
                        congestion = random.uniform(0.75, 0.98)
                    else:
                        congestion = random.uniform(0.3, 0.6)
                else:
                    if hour in [9, 10, 11, 12]:  # Weekend activity
                        congestion = random.uniform(0.4, 0.7)
                    else:
                        congestion = random.uniform(0.2, 0.5)
                
                # Add some randomness for realism
                # Rain increases congestion
                if random.random() > 0.7:  # 30% chance of rain
                    congestion = min(0.99, congestion + random.uniform(0.1, 0.2))
                
                # Accidents occasionally cause extreme congestion
                if random.random() > 0.95:  # 5% chance of accident
                    congestion = min(0.99, congestion + random.uniform(0.2, 0.3))
                
                # Calculate travel time based on congestion
                # Assuming road lengths: Mombasa Rd (15km), Thika Rd (20km), Ngong Rd (10km)
                road_lengths = {"Mombasa Road": 15, "Thika Road": 20, "Ngong Road": 10}
                road_length = road_lengths.get(road_name, 10)  # Default to 10km
                
                # Free-flow speed around 60-80 km/h
                free_flow_speed = random.uniform(60, 80)
                actual_speed = free_flow_speed * (1 - congestion)
                travel_time_minutes = (road_length / actual_speed) * 60
                
                time_entry = {
                    "timestamp": current_date.replace(hour=hour).strftime("%Y-%m-%dT%H:00:00Z"),
                    "congestionLevel": round(congestion, 2),
                    "averageSpeed": round(actual_speed, 1),
                    "travelTimeMinutes": round(travel_time_minutes, 1),
                    "freeFlowSpeed": round(free_flow_speed, 1),
                    "roadLength": road_length,
                    "isWeekday": is_weekday
                }
                
                traffic_data["data"].append(time_entry)
            
            current_date += timedelta(days=1)
        
        return traffic_data

# Example usage
if __name__ == "__main__":
    collector = NairobiDataCollector()
    
    # Get weather forecast
    weather_data = collector.get_weekly_weather_forecast()
    
    # Define roads of interest (example roads in Nairobi)
    roads_to_track = [
        {
            "name": "Mombasa Road",
            "start_lat": -1.3195,
            "start_lon": 36.8054,
            "end_lat": -1.3242,
            "end_lon": 36.9155
        },
        {
            "name": "Thika Road",
            "start_lat": -1.2571,
            "start_lon": 36.8168,
            "end_lat": -1.1452,
            "end_lon": 36.9664
        },
        {
            "name": "Ngong Road",
            "start_lat": -1.2967,
            "start_lon": 36.8111,
            "end_lat": -1.3132,
            "end_lon": 36.7496
        },
        {
            "name": "Waiyaki Way",
            "start_lat": -1.2671,
            "start_lon": 36.7851,
            "end_lat": -1.2524,
            "end_lon": 36.7138
        },
        {
            "name": "Jogoo Road",
            "start_lat": -1.2875,
            "start_lon": 36.8388,
            "end_lat": -1.2830,
            "end_lon": 36.8859
        }
    ]
    
    # Get traffic history for these roads
    traffic_data = collector.get_traffic_history(roads_to_track, days_back=30)
    
    print("Data collection complete!")
