-- Clean up existing historical data
BEGIN;

-- Delete from trips first (due to foreign key constraints)
DELETE FROM trips;

-- Delete from trip_records
DELETE FROM trip_records;

-- Delete from driver_shifts
DELETE FROM driver_shifts;

COMMIT; 