import requests
import json
from datetime import datetime, timedelta
import time
import os

class NairobiDataCollector:
    def __init__(self):
        # Set up API keys (replace with your actual API keys)
        self.weather_api_key = "2b232d61805e156a990708c8b8de2147"  # OpenWeatherMap API key
        self.traffic_api_key = "QbazkuAIJeiMNoP8PQXJ7PG1T9eG3v63"   # TomTom API key
        
        # Create data directories if they don't exist
        self.data_dir = "nairobi_data"
        os.makedirs(os.path.join(self.data_dir, "weather"), exist_ok=True)
        os.makedirs(os.path.join(self.data_dir, "traffic"), exist_ok=True)
    
    def get_weekly_weather_forecast(self):
        """
        Get 7-day weather forecast for Nairobi using OpenWeatherMap API
        and save as JSON
        """
        print("Fetching weekly weather forecast for Nairobi...")
        
        # Nairobi coordinates
        lat = -1.2921
        lon = 36.8219
        
        # API endpoint for 7-day forecast
        url = f"https://api.openweathermap.org/data/2.5/onecall?lat={lat}&lon={lon}&exclude=current,minutely,hourly,alerts&units=metric&appid={self.weather_api_key}"
        
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
            return None
    
    def get_traffic_history(self, road_list, days_back=30):
        """
        Get historical traffic data for specified roads in Nairobi
        for the past month using TomTom API and save as CSV
        
        Args:
            road_list: List of dictionaries with road info
                [{"name": "Mombasa Road", "start_lat": -1.3195, "start_lon": 36.8054, "end_lat": -1.3242, "end_lon": 36.9155}]
            days_back: Number of days to look back
        """
        print(f"Fetching traffic history for {len(road_list)} roads...")
        
        # Calculate date range
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days_back)
        
        # Format dates for API
        start_str = start_date.strftime("%Y-%m-%d")
        end_str = end_date.strftime("%Y-%m-%d")
        
        all_traffic_data = {}
        
        for road in road_list:
            road_name = road["name"]
            print(f"Processing data for {road_name}...")
            
            # Build coordinates string for start and end points
            start_point = f"{road['start_lat']},{road['start_lon']}"
            end_point = f"{road['end_lat']},{road['end_lon']}"
            
            # TomTom Traffic API endpoint for historical data
            url = f"https://api.tomtom.com/traffic/services/4/flowSegmentData/historical/pathByCoordinates/{start_point}:{end_point}/json?key={self.traffic_api_key}&startDate={start_str}&endDate={end_str}&timeSet=TD&timeFormat=RFC3339"
            
            try:
                response = requests.get(url)
                response.raise_for_status()
                
                # Process the data
                traffic_data = response.json()
                all_traffic_data[road_name] = traffic_data
                
                # Save individual road data
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = os.path.join(self.data_dir, "traffic", f"{road_name.replace(' ', '_').lower()}_{timestamp}.json")
                
                with open(filename, 'w') as f:
                    json.dump(traffic_data, f, indent=4)
                    
                print(f"Traffic data for {road_name} saved to {filename}")
                
                # Be nice to the API rate limits
                time.sleep(1)
                
            except requests.exceptions.RequestException as e:
                print(f"Error fetching traffic data for {road_name}: {e}")
        
        # Save combined data
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        combined_filename = os.path.join(self.data_dir, "traffic", f"all_roads_traffic_{timestamp}.json")
        
        with open(combined_filename, 'w') as f:
            json.dump(all_traffic_data, f, indent=4)
            
        print(f"Combined traffic data saved to {combined_filename}")
        return all_traffic_data

# Example usage
if __name__ == "__main__":
    collector = NairobiDataCollector()
    
    # Get weather forecast
    weather_data = collector.get_weekly_weather_forecast()
    
    # Define roads of interest (example roads in Nairobi)
    roads_to_track = [
        
        {
            "name": "Outering Road",
            "start_lat": -1.246004,
            "start_lon": 36.866922,
            "end_lat": -1.322967,
            "end_lon": 36.898350
        }
        
    ]
    
    # Get traffic history for these roads
    traffic_data = collector.get_traffic_history(roads_to_track, days_back=30)
    
    print("Data collection complete!")
