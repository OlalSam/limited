import requests
import json
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv
import logging

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class NairobiDataCollector:
    def __init__(self):
        load_dotenv()
        self.traffic_api_key = os.getenv("TOMTOM_API_KEY")
        self._validate_keys()
        self._create_directories()
        
        # Updated API configuration
        self.traffic_base_url = "https://api.tomtom.com/traffic/services/4/historical"
        self.max_retries = 3
        self.retry_delay = 2

    def _validate_keys(self):
        if not self.traffic_api_key:
            raise ValueError("Missing TomTom API key in environment variables")

    def _create_directories(self):
        os.makedirs("nairobi_data/traffic", exist_ok=True)

    def get_historical_traffic(self, road_list, days_back=7):
        """Get historical traffic data for specified roads"""
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days_back)
        
        # Validate date range
        if start_date > end_date:
            raise ValueError("Start date cannot be after end date")
            
        for road in road_list:
            self._process_road(road, start_date, end_date)

    def _process_road(self, road, start_date, end_date):
        road_name = road["name"]
        logger.info(f"Processing {road_name}")
        
        # Correct coordinate order (lon,lat)
        start_point = f"{road['start_lon']},{road['start_lat']}"
        end_point = f"{road['end_lon']},{road['end_lat']}"
        
        current_date = start_date
        while current_date <= end_date:
            self._get_daily_data(start_point, end_point, road_name, current_date)
            current_date += timedelta(days=1)

    def _get_daily_data(self, start_point, end_point, road_name, date):
        # Format date for API (always use past dates)
        date_str = date.strftime("%Y-%m-%d")
        time_str = "T12:00:00Z"  # Midday UTC
        
        # Build correct API endpoint
        url = (
            f"{self.traffic_base_url}/route/"
            f"{start_point}:{end_point}/json"
            f"?key={self.traffic_api_key}"
            f"&dateTime={date_str}{time_str}"
            "&interval=60"
            "&travelMode=car"
            "&fields=segments"
        )
        
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            self._save_data(response.json(), road_name, date_str)
            
        except requests.exceptions.HTTPError as e:
            logger.error(f"HTTP error for {date_str}: {e.response.status_code}")
            if e.response.status_code == 596:
                logger.error("Service not found - check API endpoint version")
        except Exception as e:
            logger.error(f"Error processing {date_str}: {str(e)}")

    def _save_data(self, data, road_name, date_str):
        filename = f"nairobi_data/traffic/{road_name}_{date_str}.json"
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)
        logger.info(f"Saved data for {date_str}")

if __name__ == "__main__":
    try:
        collector = NairobiDataCollector()
        
        roads_to_track = [
            {
                "name": "Outering Road",
                "start_lat": -1.246004,
                "start_lon": 36.866922,
                "end_lat": -1.322967,
                "end_lon": 36.898350
            }
        ]
        
        collector.get_historical_traffic(roads_to_track, days_back=7)
        logger.info("Data collection completed successfully")
        
    except Exception as e:
        logger.error(f"Critical failure: {str(e)}")
