-- Stored Function for Revenue by Locations
CREATE OR REPLACE FUNCTION get_revenue_by_locations()
RETURNS TABLE(location VARCHAR(100), total_revenue FLOAT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT l.name AS location, SUM(f.value) AS total_revenue
    FROM trips t
    JOIN fares f ON t.fare_id = f.fare_id
    JOIN stations s ON t.boarding_station_id = s.station_id
    JOIN locations l ON s.location_id = l.location_id
    GROUP BY l.name;
END;
$$;