-- Create locations table
CREATE TABLE IF NOT EXISTS drivers_location (
    driver_id UUID PRIMARY KEY,
    lat DOUBLE PRECISION NULL,
    lng DOUBLE PRECISION NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add PostGIS extension for geographic features (if using PostgreSQL)
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Index for geographic queries on locations
CREATE INDEX IF NOT EXISTS idx_locations_geo ON drivers_location USING GIST (geography(ST_MakePoint(lng, lat)));
