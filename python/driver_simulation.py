import requests
import json
from datetime import datetime, timedelta
import time
import random
import math
from typing import List, Dict, Tuple

class DriverSimulator:
    def __init__(self, base_url: str = "http://localhost:44711/Nganya/api"):
        self.base_url = base_url
        # Actual drivers from the database
        self.drivers = [
            {"username": "driver1", "name": "Samuel Olal"},
            {"username": "driver2", "name": ""},
            {"username": "driver12", "name": "Lucy Akinyi"},
            {"username": "driver3", "name": "John Mwangi"},
            {"username": "driver4", "name": "Catherine Wanjiku"},
            {"username": "driver5", "name": "David Kipchoge"},
            {"username": "driver6", "name": "Faith Njeri"},
            {"username": "driver7", "name": "George Omondi"},
            {"username": "driver8", "name": "Hellen Kamau"},
            {"username": "driver9", "name": "Isaac Mutua"},
            {"username": "driver10", "name": "Joyce Waithera"},
            {"username": "driver11", "name": "Kennedy Otieno"}
        ]

        # Actual vehicles from the database
        self.vehicles = {
            1: {"plate": "KWS 4216", "model": "Isuzu", "capacity": 40, "type": "Royal Swift"},
            3: {"plate": "KWS 42161", "model": "Isuzu", "capacity": 56, "type": "Royal Swift"},
            5: {"plate": "KDD 123A", "model": "Isuzu NQR", "capacity": 33, "type": "Super Metro"},
            6: {"plate": "KCE 456B", "model": "Toyota Coaster", "capacity": 29, "type": "Forward Travelers"},
            7: {"plate": "KBZ 789C", "model": "Mitsubishi Fuso", "capacity": 41, "type": "Embassava Sacco"},
            8: {"plate": "KDE 234D", "model": "Isuzu FRR", "capacity": 33, "type": "Metro Trans"},
            9: {"plate": "KDG 567E", "model": "Hino 300", "capacity": 25, "type": "Umoja Innercore Sacco"},
            10: {"plate": "KCF 890F", "model": "Toyota Hiace", "capacity": 14, "type": "Lopha Sacco"},
            11: {"plate": "KDB 345G", "model": "Isuzu NQR", "capacity": 33, "type": "Rembo Shuttle"},
            12: {"plate": "KDH 678H", "model": "Mercedes Benz MB917", "capacity": 37, "type": "Embakasi Shuttle"},
            13: {"plate": "KCC 901J", "model": "Toyota Coaster", "capacity": 29, "type": "Rwanda Sacco"},
            14: {"plate": "KDJ 234K", "model": "Mitsubishi Rosa", "capacity": 26, "type": "Super Metro"},
            15: {"plate": "KDF 567L", "model": "Isuzu FRR", "capacity": 33, "type": "Mwiki Sacco"},
            16: {"plate": "KCA 890M", "model": "Nissan Civilian", "capacity": 30, "type": "Kayole Shuttle"},
            17: {"plate": "KDK 123N", "model": "Toyota Coaster", "capacity": 29, "type": "City Shuttle"},
            18: {"plate": "KCB 456P", "model": "Isuzu NQR", "capacity": 33, "type": "Utawala Sacco"},
            19: {"plate": "KDL 789Q", "model": "Hino 500", "capacity": 44, "type": "KBS"}
        }

        # Route assignments from the database with valid vehicle IDs
        self.route_assignments = [
            # Format: (driver_username, route_id, vehicle_id, date)
            ("driver12", 15, 1, "2025-04-29"),  # Using vehicle_id 1 (KWS 4216)
            ("driver3", 15, 3, "2025-04-29"),   # Using vehicle_id 3 (KWS 42161)
            ("driver4", 14, 5, "2025-04-29"),   # Using vehicle_id 5 (KDD 123A)
            ("driver5", 13, 6, "2025-04-29"),   # Using vehicle_id 6 (KCE 456B)
            ("driver6", 12, 7, "2025-04-29"),   # Using vehicle_id 7 (KBZ 789C)
            ("driver7", 11, 8, "2025-04-29"),   # Using vehicle_id 8 (KDE 234D)
            ("driver8", 10, 9, "2025-04-29"),   # Using vehicle_id 9 (KDG 567E)
        ]

        # Route coordinates (using actual Nairobi coordinates)
        self.routes = {
            10: {"name": "Route 10", "coordinates": [
                (-1.283793, 36.814932),  # CBD
                (-1.297579, 36.819990),  # Ngong
            ]},
            11: {"name": "Route 11", "coordinates": [
                (-1.283793, 36.814932),  # CBD
                (-1.278729, 36.834377),  # Westlands
            ]},
            12: {"name": "Route 12", "coordinates": [
                (-1.283793, 36.814932),  # CBD
                (-1.1452, 36.9664),      # Thika
            ]},
            13: {"name": "Route 13", "coordinates": [
                (-1.283793, 36.814932),  # CBD
                (-1.234116, 36.868210),  # Eastlands
            ]},
            14: {"name": "Route 14", "coordinates": [
                (-1.283793, 36.814932),  # CBD
                (-1.323920, 36.939121),  # South B
            ]},
            15: {"name": "Route 15", "coordinates": [
                (-1.283793, 36.814932),  # CBD
                (-1.358592, 36.863803),  # Industrial Area
            ]}
        }

        # Base fare for each route (in KES)
        self.route_fares = {
            10: 50,   # CBD to Ngong
            11: 40,   # CBD to Westlands
            12: 100,  # CBD to Thika
            13: 30,   # CBD to Eastlands
            14: 35,   # CBD to South B
            15: 45    # CBD to Industrial Area
        }

    def login_driver(self, driver: Dict) -> bool:
        """Simulate driver login"""
        try:
            print(f"Driver {driver['username']} ({driver['name']}) logged in successfully")
            return True
        except Exception as e:
            print(f"Login failed for {driver['username']}: {str(e)}")
            return False

    def simulate_trip(self, driver: Dict, route_id: int, start_time: datetime = None):
        """Simulate a complete trip for a driver"""
        if start_time is None:
            start_time = datetime.now()
        
        if route_id not in self.routes:
            print(f"Route {route_id} not found")
            return

        route = self.routes[route_id]
        
        # Login driver
        if not self.login_driver(driver):
            return
        
        # Check if driver has an active assignment for the trip date
        trip_date = start_time.strftime("%Y-%m-%d")
        has_assignment = any(
            a[0] == driver["username"] and a[1] == route_id and a[3] == trip_date
            for a in self.route_assignments
        )
        
        if not has_assignment:
            print(f"Driver {driver['username']} has no active assignment for route {route_id} on {trip_date}")
            return
        
        # Get vehicle details from assignment
        vehicle_id = next(a[2] for a in self.route_assignments if a[0] == driver["username"] and a[1] == route_id and a[3] == trip_date)
        vehicle = self.vehicles.get(vehicle_id)
        
        if not vehicle:
            print(f"Vehicle {vehicle_id} not found")
            return
        
        # Generate random passenger count (between 5 and vehicle capacity)
        max_passengers = min(vehicle["capacity"], 30)  # Cap at 30 for simulation
        passenger_count = random.randint(5, max_passengers)
        
        # Calculate fare based on route and passenger count
        base_fare = self.route_fares[route_id]
        total_fare = base_fare * passenger_count
        
        # Start trip
        start_coords = route["coordinates"][0]
        response = self._make_api_call(
            "startTrip",
            driver["username"],
            start_coords[0],
            start_coords[1],
            passenger_count,
            vehicle_id
        )
        if response and response.status_code == 200:
            print(f"Driver {driver['username']} started trip on route {route['name']} with {passenger_count} passengers in {vehicle['plate']} ({vehicle['type']})")
        else:
            print(f"Failed to start trip for {driver['username']}")
            return
        
        # Simulate trip duration (between 20-40 minutes)
        trip_duration = random.randint(20, 40)
        print(f"Simulating trip duration of {trip_duration} minutes...")
        time.sleep(trip_duration)  # Simulate the trip duration
        
        # End trip
        end_coords = route["coordinates"][1]
        response = self._make_api_call(
            "endTrip",
            driver["username"],
            end_coords[0],
            end_coords[1],
            total_fare,
            vehicle_id
        )
        if response and response.status_code == 200:
            print(f"Driver {driver['username']} completed trip on route {route['name']} with fare KES {total_fare}")
        else:
            print(f"Failed to end trip for {driver['username']}")

    def generate_historical_data(self, days: int = 40):
        """Generate historical data for the past N days"""
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        current_date = start_date
        
        while current_date <= end_date:
            date_str = current_date.strftime("%Y-%m-%d")
            print(f"\nGenerating trips for {date_str}")
            
            # Get assignments for this date
            day_assignments = [a for a in self.route_assignments if a[3] == date_str]
            
            for assignment in day_assignments:
                driver_username, route_id, vehicle_id, _ = assignment
                
                # Find driver by username
                driver = next((d for d in self.drivers if d["username"] == driver_username), None)
                if not driver:
                    print(f"Driver {driver_username} not found")
                    continue
                
                # Generate 2-3 trips per assignment
                num_trips = random.randint(2, 3)
                for trip in range(num_trips):
                    # Generate random start time during the day
                    hour = random.randint(6, 20)  # Between 6 AM and 8 PM
                    minute = random.randint(0, 59)
                    trip_time = current_date.replace(hour=hour, minute=minute)
                    
                    self.simulate_trip(driver, route_id, trip_time)
                    time.sleep(1)  # Small delay between trips
            
            current_date += timedelta(days=1)

    def _make_api_call(self, action: str, driver_id: str, lat: float, lng: float, additional_data: float = None, vehicle_id: int = None) -> requests.Response:
        """Make API call to the MapController"""
        try:
            url = f"{self.base_url}/mapController/{action}"
            params = {
                "driverId": driver_id,
                "lat": lat,
                "lng": lng
            }
            
            if vehicle_id is not None:
                params["vehicleId"] = vehicle_id
            
            if additional_data is not None:
                if action == "startTrip":
                    params["passengerCount"] = int(additional_data)
                elif action == "endTrip":
                    params["fare"] = additional_data
            
            print(f"\nMaking API call to: {url}")
            print(f"Parameters: {params}")
            
            response = requests.post(url, params=params, timeout=10)
            
            if response.status_code != 200:
                print(f"API call failed with status code: {response.status_code}")
                print(f"Response content: {response.text}")
            else:
                print(f"API call successful: {response.text}")
                
            return response
        except requests.exceptions.ConnectionError as e:
            print(f"Connection error: Could not connect to {url}")
            print(f"Error details: {str(e)}")
            return None
        except requests.exceptions.Timeout as e:
            print(f"Timeout error: Request timed out after 10 seconds")
            print(f"Error details: {str(e)}")
            return None
        except Exception as e:
            print(f"Unexpected error during API call: {str(e)}")
            return None

    @staticmethod
    def _calculate_distance(coord1: Tuple[float, float], coord2: Tuple[float, float]) -> float:
        """Calculate distance between two coordinates in kilometers"""
        R = 6371  # Earth's radius in kilometers
        
        lat1, lon1 = math.radians(coord1[0]), math.radians(coord1[1])
        lat2, lon2 = math.radians(coord2[0]), math.radians(coord2[1])
        
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        
        a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        
        return R * c

if __name__ == "__main__":
    simulator = DriverSimulator()
    
    # Generate historical data for the past 40 days
    print("Generating historical data for the past 40 days...")
    simulator.generate_historical_data(days=40)
    print("Historical data generation completed!") 