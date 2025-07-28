-- Create driver_shifts table
CREATE TABLE IF NOT EXISTS driver_shifts (
    id SERIAL PRIMARY KEY,
    driver_username VARCHAR(50) NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT driver_shifts_status_check CHECK (status IN ('active', 'completed', 'cancelled'))
);

-- Create indexes for driver_shifts
CREATE INDEX IF NOT EXISTS idx_driver_shifts_username ON driver_shifts(driver_username);
CREATE INDEX IF NOT EXISTS idx_driver_shifts_start_time ON driver_shifts(start_time);
CREATE INDEX IF NOT EXISTS idx_driver_shifts_status ON driver_shifts(status);

-- Create trip_records table
CREATE TABLE IF NOT EXISTS trip_records (
    id SERIAL PRIMARY KEY,
    driver_username VARCHAR(50) NOT NULL,
    trip_date TIMESTAMP WITH TIME ZONE NOT NULL,
    passenger_count INTEGER NOT NULL DEFAULT 0,
    route_id INTEGER,
    vehicle_id INTEGER,
    status VARCHAR(20) NOT NULL DEFAULT 'completed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT trip_records_status_check CHECK (status IN ('in_progress', 'completed', 'cancelled'))
);

-- Create indexes for trip_records
CREATE INDEX IF NOT EXISTS idx_trip_records_username ON trip_records(driver_username);
CREATE INDEX IF NOT EXISTS idx_trip_records_date ON trip_records(trip_date);
CREATE INDEX IF NOT EXISTS idx_trip_records_status ON trip_records(status); 