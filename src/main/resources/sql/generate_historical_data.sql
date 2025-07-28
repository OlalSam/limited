-- Generate historical driver shifts and trip records
-- This script should be run outside the project

-- Function to generate random number between min and max
CREATE OR REPLACE FUNCTION random_between(min_val INTEGER, max_val INTEGER) 
RETURNS INTEGER AS $$
BEGIN
    RETURN floor(random() * (max_val - min_val + 1) + min_val);
END;
$$ LANGUAGE plpgsql;

-- Function to generate random timestamp within a day
CREATE OR REPLACE FUNCTION random_time_on_day(day DATE) 
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
    RETURN day + (random() * interval '1 day');
END;
$$ LANGUAGE plpgsql;

-- Function to generate random fare based on route and passenger count
CREATE OR REPLACE FUNCTION generate_fare(route_id INTEGER, passenger_count INTEGER) 
RETURNS NUMERIC AS $$
DECLARE
    base_fare NUMERIC;
BEGIN
    -- Base fare varies by route (50-100 KES)
    base_fare := random_between(50, 100);
    -- Add small random variation
    base_fare := base_fare + (random() * 10);
    -- Multiply by passenger count
    RETURN base_fare * passenger_count;
END;
$$ LANGUAGE plpgsql;

-- Generate driver shifts for the past 30 days
DO $$
DECLARE
    driver RECORD;
    shift_date DATE;
    start_time TIMESTAMP WITH TIME ZONE;
    end_time TIMESTAMP WITH TIME ZONE;
    shift_status TEXT;
    trip_start TIMESTAMP WITH TIME ZONE;
    trip_end TIMESTAMP WITH TIME ZONE;
    passenger_count INTEGER;
    route_id INTEGER;
    vehicle_id INTEGER;
    fare NUMERIC;
BEGIN
    -- For each driver (user with role='DRIVER')
    FOR driver IN 
        SELECT username 
        FROM users 
        WHERE role = 'DRIVER'
    LOOP
        -- For the past 30 days
        FOR shift_date IN 
            SELECT CURRENT_DATE - (n || ' days')::INTERVAL
            FROM generate_series(0, 29) n
        LOOP
            -- Generate 1-2 shifts per day
            FOR i IN 1..random_between(1, 2) LOOP
                -- Morning shift (5:30 - 14:30) or Evening shift (15:00 - 22:30)
                IF random() < 0.5 THEN
                    start_time := shift_date + '05:30:00'::TIME + (random() * interval '2 hours');
                    end_time := start_time + interval '9 hours';
                ELSE
                    start_time := shift_date + '15:00:00'::TIME + (random() * interval '1 hour');
                    end_time := start_time + interval '7.5 hours';
                END IF;

                -- 90% chance of completed shift, 10% chance of cancelled
                shift_status := CASE WHEN random() < 0.9 THEN 'completed' ELSE 'cancelled' END;

                -- Insert shift
                INSERT INTO driver_shifts (driver_username, start_time, end_time, status)
                VALUES (driver.username, start_time, 
                        CASE WHEN shift_status = 'completed' THEN end_time ELSE NULL END,
                        shift_status);

                -- If shift was completed, generate trip records
                IF shift_status = 'completed' THEN
                    -- Generate 8-12 trips per shift
                    FOR j IN 1..random_between(8, 12) LOOP
                        -- Calculate trip times
                        trip_start := start_time + (j * interval '45 minutes');
                        trip_end := trip_start + interval '30 minutes';
                        
                        -- Get random route and vehicle
                        SELECT id INTO route_id FROM routes ORDER BY random() LIMIT 1;
                        SELECT id INTO vehicle_id FROM vehicle ORDER BY random() LIMIT 1;
                        
                        -- Generate passenger count (15-40)
                        passenger_count := random_between(15, 40);
                        
                        -- Generate fare
                        fare := generate_fare(route_id, passenger_count);
                        
                        -- Insert into trip_records
                        INSERT INTO trip_records (
                            driver_username,
                            trip_date,
                            passenger_count,
                            route_id,
                            vehicle_id,
                            status
                        )
                        VALUES (
                            driver.username,
                            trip_start,
                            passenger_count,
                            route_id,
                            vehicle_id,
                            'completed'
                        );
                        
                        -- Insert into trips using the username to get the user ID
                        INSERT INTO trips (
                            driver_id,
                            fare,
                            route_id,
                            start_time,
                            end_time
                        )
                        SELECT 
                            u.id,
                            fare,
                            route_id,
                            trip_start,
                            trip_end
                        FROM users u
                        WHERE u.username = driver.username;
                    END LOOP;
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

-- Clean up temporary functions
DROP FUNCTION IF EXISTS random_between(INTEGER, INTEGER);
DROP FUNCTION IF EXISTS random_time_on_day(DATE);
DROP FUNCTION IF EXISTS generate_fare(INTEGER, INTEGER); 