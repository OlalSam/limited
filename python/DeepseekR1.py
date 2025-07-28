import requests
import json
from datetime import datetime, timedelta
import time
import os
import logging

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class NairobiDataCollector:
    def __init__(self):


        self.weather_api_key = "2b232d61805e156a990708c8b8de2147"#os.getenv("OPENWEATHER_API_KEY")
        self.traffic_api_key = " ywGBdATh8DKWpJvmaKhZuBTdPJDCIPpT"#os.getenv("TOMTOM_API_KEY")
        
        # Validate API keys
        if not self.weather_api_key or not self.traffic_api_key:
            raise ValueError("Missing API keys in environment variables")
        
        # Create data directories
        self.data_dir = "nairobi_data"
        self._create_directories()
        
        # API configuration
        self.traffic_base_url = "https://api.tomtom.com/traffic/historical/4/route"
        self.max_retries = 3
        self.retry_delay = 2  # seconds

    def _create_directories(self):
        """Create required directory structure"""
        os.makedirs(os.path.join(self.data_dir, "weather"), exist_ok=True)
        os.makedirs(os.path.join(self.data_dir, "traffic"), exist_ok=True)

    def _make_api_request(self, url, params=None):
        """Generic API request handler with retry logic"""
        for attempt in range(self.max_retries):
            try:
                response = requests.get(url, params=params)
                response.raise_for_status()
                return response.json()
            except requests.exceptions.HTTPError as err:
                if response.status_code == 429:  # Rate limited
                    retry_after = int(response.headers.get('Retry-After', 30))
                    logger.warning(f"Rate limited. Retrying after {retry_after} seconds")
                    time.sleep(retry_after)
                    continue
                logger.error(f"HTTP error: {err}")
            except requests.exceptions.RequestException as err:
                logger.error(f"Request error: {err}")
            
            if attempt < self.max_retries - 1:
                logger.info(f"Retrying... (Attempt {attempt + 2}/{self.max_retries})")
                time.sleep(self.retry_delay)
        
        return None

    def get_weekly_weather_forecast(self):
        """Get 7-day weather forecast for Nairobi using OpenWeatherMap API"""
        logger.info("Fetching weekly weather forecast...")
        
        params = {
            'lat': -1.2921,
            'lon': 36.8219,
            'exclude': 'current,minutely,hourly,alerts',
            'units': 'metric',
            'appid': self.weather_api_key
        }
        
        data = self._make_api_request("https://api.openweathermap.org/data/2.5/onecall", params)
        
        if data:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = os.path.join(self.data_dir, "weather", f"forecast_{timestamp}.json")
            self._save_json(data, filename)
        
        return data

    def get_historical_traffic(self, road_list, days_back=30):
        """Get historical traffic data for specified roads"""
        logger.info(f"Fetching traffic history for {len(road_list)} roads...")
        
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days_back)
        current_date = start_date
        
        all_traffic_data = {}
        
        while current_date <= end_date:
            date_str = current_date.strftime("%Y-%m-%d")
            logger.info(f"Processing data for {date_str}")
            
            for road in road_list:
                road_name = road["name"]
                logger.info(f"Collecting data for {road_name}")
                
                # Construct route coordinates
                waypoints = [
                    f"{road['start_lat']},{road['start_lon']}",
                    f"{road['end_lat']},{road['end_lon']}"
                ]
                coordinates = ":".join(waypoints)
                
                # Build API request URL
                url = f"{self.traffic_base_url}/{coordinates}/json"
                
                params = {
                    'key': self.traffic_api_key,
                    'dateTime': current_date.replace(hour=12, minute=0, second=0).isoformat() + "Z",
                    'interval': 60,  # 60-minute aggregation window
                    'maxAlternatives': 2,
                    'travelMode': "car",
                    'fields': 'routes/summary,routes/segments'
                }
                
                data = self._make_api_request(url, params)
                
                if data:
                    # Store data by date and road
                    if date_str not in all_traffic_data:
                        all_traffic_data[date_str] = {}
                    all_traffic_data[date_str][road_name] = data
                    
                    # Save individual road data
                    filename = os.path.join(
                        self.data_dir,
                        "traffic",
                        f"{road_name.replace(' ', '_').lower()}_{date_str}.json"
                    )
                    self._save_json(data, filename)
            
            current_date += timedelta(days=1)
            time.sleep(1)  # Be nice to the API
        
        # Save combined data
        combined_filename = os.path.join(
            self.data_dir,
            "traffic",
            f"combined_traffic_{start_date.strftime('%Y%m%d')}_to_{end_date.strftime('%Y%m%d')}.json"
        )
        self._save_json(all_traffic_data, combined_filename)
        
        return all_traffic_data

    def _save_json(self, data, filename):
        """Save JSON data to file with error handling"""
        try:
            with open(filename, 'w') as f:
                json.dump(data, f, indent=4)
            logger.info(f"Data saved to {filename}")
        except IOError as e:
            logger.error(f"Failed to save {filename}: {e}")

if __name__ == "__main__":
    try:
        collector = NairobiDataCollector()
        
        # Get weather forecast
        weather_data = collector.get_weekly_weather_forecast()
        
        # Define roads to monitor
        roads_to_track = [
            {
                "name": "Outering Road",
                "start_lat": -1.246004,
                "start_lon": 36.866922,
                "end_lat": -1.322967,
                "end_lon": 36.898350
            }
        ]
        
        # Get traffic history (last 7 days for testing)
        traffic_data = collector.get_historical_traffic(roads_to_track, days_back=7)
        
        logger.info("Data collection complete!")
    
    except Exception as e:
        logger.error(f"Fatal error in main execution: {e}")
