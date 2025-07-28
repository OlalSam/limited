import random
from datetime import datetime, timedelta
import psycopg2
from psycopg2.extras import execute_values

# Database connection parameters
DB_PARAMS = {
    'dbname': 'nganya1',
    'user': 'olal',
    'password': '$@m01011001',
    'host': 'localhost',
    'port': '5432'
}

def generate_trip_data(start_date, end_date):
    # Sample data for realistic generation
    drivers = [16, 7, 8, 9, 10, 11, 12, 14, 15, 2, 30, 28]  # Existing driver IDs
    vehicles = [1, 3, 6, 8, 9, 10, 11, 32, 34, 36]  # Existing vehicle IDs
    routes = [4, 5, 6, 7, 8, 9]  # Existing route IDs
    
    trips = []
    current_date = start_date
    
    while current_date <= end_date:
        # Target daily revenue between 8,000-15,000
        target_daily_revenue = random.randint(8000, 15000)
        daily_trips = []
        current_daily_revenue = 0
        
        # Generate trips until we reach target revenue
        while current_daily_revenue < target_daily_revenue:
            # Generate trip start time between 5 AM and 10 PM
            hour = random.randint(5, 22)
            minute = random.randint(0, 59)
            start_time = current_date.replace(hour=hour, minute=minute)
            
            # Trip duration between 20-50 minutes
            duration = timedelta(minutes=random.randint(20, 50))
            end_time = start_time + duration
            
            # Select random driver, vehicle, and route
            driver_id = random.choice(drivers)
            vehicle_id = random.choice(vehicles)
            route_id = random.choice(routes)
            
            # Generate passenger count with varying ranges based on time of day
            if 5 <= hour < 7:  # Early morning
                passenger_count = random.randint(3, 15)
            elif 7 <= hour < 9:  # Morning rush
                passenger_count = random.randint(15, 35)
            elif 9 <= hour < 16:  # Mid-day
                passenger_count = random.randint(8, 25)
            elif 16 <= hour < 19:  # Evening rush
                passenger_count = random.randint(15, 35)
            else:  # Late evening
                passenger_count = random.randint(5, 20)
            
            # Calculate fare with varying rates based on time of day
            if 5 <= hour < 7 or hour >= 20:  # Early morning or late evening
                base_fare = 200  # Higher base fare for off-peak
                per_passenger = 20
            elif 7 <= hour < 9 or 16 <= hour < 19:  # Rush hours
                base_fare = 150
                per_passenger = 25  # Higher per passenger rate during rush
            else:  # Regular hours
                base_fare = 150
                per_passenger = 15
            
            fare = (passenger_count * per_passenger) + base_fare
            
            # Calculate expenses (30-40% of fare) and profit
            expense_percentage = random.uniform(0.3, 0.4)  # Varying expense percentage
            expenses = round(fare * expense_percentage, 2)
            profit = round(fare - expenses, 2)
            
            trip = {
                'driver_id': driver_id,
                'vehicle_id': vehicle_id,
                'route_id': route_id,
                'start_time': start_time,
                'end_time': end_time,
                'fare': fare,
                'status': 'completed',
                'revenue': fare,
                'expenses': expenses,
                'profit': profit
            }
            
            # Only add trip if it doesn't exceed target revenue
            if current_daily_revenue + fare <= target_daily_revenue * 1.1:  # Allow 10% overflow
                daily_trips.append(trip)
                current_daily_revenue += fare
            else:
                break
        
        trips.extend(daily_trips)
        print(f"Generated {len(daily_trips)} trips for {current_date.date()} with revenue: {current_daily_revenue:.2f}")
        current_date += timedelta(days=1)
    
    return trips

def insert_trip_data(trips):
    conn = psycopg2.connect(**DB_PARAMS)
    cur = conn.cursor()
    
    try:
        BATCH_SIZE = 10  # Insert 10 trips at a time
        total_inserted = 0
        all_trip_ids = []
        
        # Process trips in batches
        for i in range(0, len(trips), BATCH_SIZE):
            batch = trips[i:i + BATCH_SIZE]
            print(f"\nProcessing batch {i//BATCH_SIZE + 1} of {(len(trips) + BATCH_SIZE - 1)//BATCH_SIZE}")
            
            # Insert trips in current batch
            trip_values = [(
                t['driver_id'],
                t['fare'],
                t['route_id'],
                t['start_time'],
                t['end_time'],
                None,  # driver_username
                t['status'],
                t['vehicle_id']
            ) for t in batch]
            
            try:
                # Insert batch of trips
                execute_values(cur, """
                    INSERT INTO trips (driver_id, fare, route_id, start_time, end_time,
                                     driver_username, status, vehicle_id)
                    VALUES %s
                    RETURNING trip_id
                """, trip_values)
                
                # Get the generated trip_ids for this batch
                batch_trip_ids = [row[0] for row in cur.fetchall()]
                all_trip_ids.extend(batch_trip_ids)
                
                # Insert financials for this batch
                financial_values = [(
                    batch_trip_ids[j],  # trip_id
                    batch[j]['revenue'],
                    batch[j]['expenses'],
                    batch[j]['profit']
                ) for j in range(len(batch_trip_ids))]
                
                execute_values(cur, """
                    INSERT INTO financials (trip_id, revenue, expenses, profit)
                    VALUES %s
                """, financial_values)
                
                conn.commit()
                total_inserted += len(batch_trip_ids)
                print(f"Successfully inserted batch of {len(batch_trip_ids)} trips")
                
            except Exception as e:
                conn.rollback()
                print(f"Error in batch {i//BATCH_SIZE + 1}: {str(e)}")
                print("Failed batch values:", trip_values[0] if trip_values else "No values")
                continue
        
        print(f"\nTotal trips successfully inserted: {total_inserted} out of {len(trips)}")
        
    except Exception as e:
        conn.rollback()
        print(f"Error in main process: {str(e)}")
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    # Generate data for the past 4 months
    end_date = datetime.now()
    start_date = end_date - timedelta(days=120)  # 4 months
    
    print(f"Generating data from {start_date} to {end_date}")
    
    # Clean existing data first
    conn = psycopg2.connect(**DB_PARAMS)
    cur = conn.cursor()
    try:
        print("Cleaning existing data...")
        cur.execute("DELETE FROM financials")
        cur.execute("DELETE FROM trips")
        conn.commit()
        print("Successfully cleaned existing data")
    except Exception as e:
        conn.rollback()
        print(f"Error cleaning data: {str(e)}")
    finally:
        cur.close()
        conn.close()
    
    # Generate and insert new data
    trips = generate_trip_data(start_date, end_date)
    print(f"Generated {len(trips)} trips")
    if trips:
        print("Sample trip data:", trips[0])
    insert_trip_data(trips)