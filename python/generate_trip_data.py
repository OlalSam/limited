import random
from datetime import datetime, timedelta
import psycopg2
from psycopg2.extras import execute_batch

def generate_trip_data():
    # Connect to the database
    conn = psycopg2.connect(
        dbname="nganya1",
        user="olal",
        password="$@m01011001",
        host="localhost",
        port="5432"
    )
    cur = conn.cursor()
    
    try:
        # First, clean up existing data
        cur.execute("DELETE FROM financials")
        cur.execute("DELETE FROM trips")
        
        # Base fares for each route
        route_fares = {
            4: 70,   # CBD to Embakasi
            5: 50,   # CBD to Kayole
            6: 50,   # CBD to Umoja
            7: 100,  # CBD to Utawala
            8: 70    # CBD to Komarock
        }

        # Vehicle capacities from the database
        vehicle_capacities = {
            1: 40,   # KWS 4216 - Royal Swift
            3: 56,   # KWS 42161 - Royal Swift
            5: 33,   # KDD 123A - Super Metro
            6: 29,   # KCE 456B - Forward Travelers
            7: 41,   # KBZ 789C - Embassava Sacco
            8: 33,   # KDE 234D - Metro Trans
            9: 25,   # KDG 567E - Umoja Innercore Sacco
            10: 14,  # KCF 890F - Lopha Sacco
            11: 33,  # KDB 345G - Rembo Shuttle
            12: 37,  # KDH 678H - Embakasi Shuttle
            13: 29,  # KCC 901J - Rwanda Sacco
            14: 26,  # KDJ 234K - Super Metro
            15: 33,  # KDF 567L - Mwiki Sacco
            16: 30,  # KCA 890M - Kayole Shuttle
            17: 29,  # KDK 123N - City Shuttle
            18: 33,  # KCB 456P - Utawala Sacco
            19: 44   # KDL 789Q - KBS
        }

        # Driver usernames mapping
        driver_usernames = {
            2: "driver1",    # samuel Olal
            4: "driver2",    # driver2
            7: "driver3",    # John Mwangi
            8: "driver4",    # Catherine Wanjiku
            9: "driver5",    # David Kipchoge
            10: "driver6",   # Faith Njeri
            11: "driver7",   # George Omondi
            12: "driver8",   # Hellen Kamau
            13: "driver9",   # Isaac Mutua
            14: "driver10",  # Joyce Waithera
            15: "driver11",  # Kennedy Otieno
            16: "driver12"   # Lucy Akinyi
        }

        # Available vehicles for each route type
        route_vehicles = {
            4: [7, 8, 12],    # Embakasi route - larger vehicles
            5: [5, 9, 14],    # Kayole route - medium vehicles
            6: [6, 10, 17],   # Umoja route - smaller vehicles
            7: [1, 3, 19],    # Utawala route - largest vehicles
            8: [11, 15, 18]   # Komarock route - medium vehicles
        }

        trip_data = []
        financial_data = []
        
        # Generate dates for the past 180 days (6 months)
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=180)
        dates = [(start_date + timedelta(days=x)).strftime('%Y-%m-%d') for x in range(181)]
        
        # Driver rotation patterns (to ensure varied assignments)
        driver_groups = [
            [13, 9, 8, 7],      # Group 1
            [2, 16, 15, 14],    # Group 2
            [10, 11, 12, 4]     # Group 3
        ]

        for date in dates:
            # Determine which drivers work based on the day
            day_of_week = datetime.strptime(date, '%Y-%m-%d').weekday()
            
            # Different assignment patterns for weekdays and weekends
            if day_of_week < 5:  # Monday-Friday
                num_assignments = 8  # More trips on weekdays
                working_drivers = random.sample(driver_groups[0], 2) + \
                                random.sample(driver_groups[1], 3) + \
                                random.sample(driver_groups[2], 3)
            else:  # Weekend
                num_assignments = 6  # Fewer trips on weekends
                working_drivers = random.sample(driver_groups[0], 2) + \
                                random.sample(driver_groups[1], 2) + \
                                random.sample(driver_groups[2], 2)

            # Create assignments for the day
            day_assignments = []
            for driver_id in working_drivers:
                # Assign random route and matching vehicle
                route_id = random.choice(list(route_fares.keys()))
                vehicle_id = random.choice(route_vehicles[route_id])
                day_assignments.append((driver_id, route_id, vehicle_id))
            
            for driver_id, route_id, vehicle_id in day_assignments:
                # Generate 2-4 trips per assignment (more variation)
                num_trips = random.randint(2, 4)
                
                for _ in range(num_trips):
                    # Generate random start time during the day
                    if day_of_week < 5:  # Weekday
                        # More trips during rush hours (6-9 AM and 4-7 PM)
                        if random.random() < 0.6:  # 60% chance of rush hour
                            hour = random.choice(list(range(6, 10)) + list(range(16, 20)))
                        else:
                            hour = random.randint(10, 15)
                    else:  # Weekend
                        hour = random.randint(8, 19)  # More evenly distributed
                    
                    minute = random.randint(0, 59)
                    start_time = datetime.strptime(f"{date} {hour:02d}:{minute:02d}:00", "%Y-%m-%d %H:%M:%S")
                    
                    # Trip duration varies by time of day
                    if hour in [7, 8, 17, 18]:  # Rush hours
                        duration = random.randint(30, 50)  # Longer during rush hour
                    else:
                        duration = random.randint(20, 35)  # Normal duration
                    end_time = start_time + timedelta(minutes=duration)
                    
                    # Generate passenger count (higher during rush hours)
                    max_passengers = min(vehicle_capacities[vehicle_id], 30)
                    if hour in [7, 8, 17, 18]:  # Rush hours
                        passenger_count = random.randint(max_passengers // 2, max_passengers)
                    else:
                        passenger_count = random.randint(5, (max_passengers * 2) // 3)
                    
                    # Calculate fare
                    base_fare = route_fares[route_id]
                    total_fare = base_fare * passenger_count
                    
                    # Insert trip and get its ID
                    cur.execute("""
                        INSERT INTO trips (driver_id, fare, route_id, start_time, end_time,
                            driver_username, status, vehicle_id)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                        RETURNING trip_id
                    """, (
                        driver_id,
                        total_fare,
                        route_id,
                        start_time,
                        end_time,
                        driver_usernames[driver_id],
                        'completed',
                        vehicle_id
                    ))
                    
                    trip_id = cur.fetchone()[0]
                    
                    # Insert financial record immediately after the trip
                    cur.execute("""
                        INSERT INTO financials (trip_id, revenue, expenses, profit)
                        VALUES (%s, %s, %s, %s)
                    """, (
                        trip_id,
                        total_fare,  # Revenue equals fare
                        total_fare * 0.3,  # 30% expenses
                        total_fare * 0.7   # 70% profit
                    ))

        # Commit all changes
        conn.commit()
        
        # Get total number of records
        cur.execute("SELECT COUNT(*) FROM trips")
        trip_count = cur.fetchone()[0]
        print(f"Successfully inserted {trip_count} trips and financial records!")

    except Exception as e:
        print(f"Error: {str(e)}")
        conn.rollback()
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    generate_trip_data() 