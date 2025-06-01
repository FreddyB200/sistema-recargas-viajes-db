CREATE TABLE users (
  user_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  first_name TEXT,
  last_name TEXT,
  contact_number TEXT,
  email TEXT UNIQUE,
  gender TEXT, -- M, F, O (Other)
  date_of_birth DATE,
  residential_address TEXT,
  id_number TEXT UNIQUE, -- National ID
  city_of_birth TEXT,
  registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE locations ( -- Could represent "Zonas de Operación" or broader areas
  location_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name TEXT UNIQUE, -- e.g., Usaquén, Suba, Fontibón
  description TEXT
);

CREATE TABLE concessionaires (
  concessionaire_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name TEXT UNIQUE NOT NULL,
  operates_troncal BOOLEAN DEFAULT FALSE,
  operates_zonal_uce BOOLEAN DEFAULT FALSE,
  operates_zonal_alimentacion BOOLEAN DEFAULT FALSE,
  operates_cable BOOLEAN DEFAULT FALSE
);

CREATE TABLE vehicles (
  vehicle_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  license_plate TEXT UNIQUE,
  vehicle_type TEXT NOT NULL, -- e.g., 'ARTICULADO', 'BIARTICULADO', 'PADRON_DUAL', 'BUS_80', 'BUS_50', 'BUS_40', 'BUS_19', 'ALIMENTADOR_80', 'ALIMENTADOR_50', 'CABLE_CABIN'
  capacity INTEGER,
  technology TEXT, -- e.g., 'ELECTRICO', 'GNV', 'HIBRIDO', 'DIESEL_EURO_V', 'DIESEL_EURO_VI'
  model_year INTEGER,
  concessionaire_id BIGINT REFERENCES concessionaires(concessionaire_id),
  status TEXT DEFAULT 'active' -- e.g., active, maintenance, inactive
);

CREATE TABLE stations (
  station_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name TEXT NOT NULL,
  station_code TEXT UNIQUE, -- e.g., A001, B078, KLP01 (for paraderos) - needs a good system
  station_type TEXT NOT NULL, -- 'PORTAL', 'TRONCAL_SIMPLE', 'TRONCAL_INTERMEDIA', 'TRONCAL_CABECERA', 'CABLE', 'ZONAL_PARADERO'
  address TEXT,
  location_id BIGINT REFERENCES locations(location_id), -- Broader zone
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  has_cycle_parking BOOLEAN DEFAULT FALSE,
  cycle_parking_spots INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE routes (
  route_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  route_code TEXT UNIQUE NOT NULL, -- e.g., 'T11', 'A60', '18-3', 'C1' (Cable)
  route_name TEXT, -- e.g., "Portal Américas - Portal Dorado"
  route_type TEXT NOT NULL, -- 'TRONCAL', 'ZONAL_UCE', 'ALIMENTADORA', 'CABLE'
  origin_station_id BIGINT REFERENCES stations(station_id),
  destination_station_id BIGINT REFERENCES stations(station_id),
  concessionaire_id BIGINT REFERENCES concessionaires(concessionaire_id), -- Who operates this route primarily
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE intermediate_stations ( -- Defines the sequence of stations in a route
  intermediate_station_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  route_id BIGINT NOT NULL REFERENCES routes(route_id),
  station_id BIGINT NOT NULL REFERENCES stations(station_id),
  sequence_order INTEGER NOT NULL, -- Order of the station in the route
  UNIQUE (route_id, station_id),
  UNIQUE (route_id, sequence_order)
);

CREATE TABLE cards (
  card_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  card_number TEXT UNIQUE, -- Actual number on the card, if simulated
  user_id BIGINT REFERENCES users(user_id),
  acquisition_date DATE DEFAULT CURRENT_DATE,
  status TEXT DEFAULT 'active', -- e.g., active, inactive, blocked, lost
  balance DOUBLE PRECISION DEFAULT 0,
  last_used_date TIMESTAMP,
  update_date DATE DEFAULT CURRENT_DATE -- Last modification of card record
);

CREATE TABLE recharge_points (
  recharge_point_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  location_id BIGINT REFERENCES locations(location_id),
  operator TEXT -- e.g., "External Network", "Station Kiosk"
);

CREATE TABLE fares (
  fare_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  fare_type TEXT NOT NULL, -- e.g., 'STANDARD', 'TRANSFER', 'ELDERLY', 'STUDENT'
  value DOUBLE PRECISION NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE, -- Null if currently active
  description TEXT
);

CREATE TABLE recharges (
  recharge_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  card_id BIGINT NOT NULL REFERENCES cards(card_id),
  recharge_point_id BIGINT REFERENCES recharge_points(recharge_point_id), -- Can be null if recharge is via other means (e.g. online)
  amount DOUBLE PRECISION NOT NULL,
  recharge_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  transaction_id TEXT UNIQUE -- External transaction ID if applicable
);

CREATE TABLE trips (
  trip_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  card_id BIGINT NOT NULL REFERENCES cards(card_id),
  vehicle_id BIGINT REFERENCES vehicles(vehicle_id), -- Vehicle used for this leg
  route_id BIGINT REFERENCES routes(route_id), -- Route taken for this leg
  boarding_station_id BIGINT REFERENCES stations(station_id),
  disembarking_station_id BIGINT REFERENCES stations(station_id), -- Crucial for destination analysis
  boarding_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  disembarking_time TIMESTAMP,
  fare_id BIGINT REFERENCES fares(fare_id), -- Fare applied for this trip/transfer
  is_transfer BOOLEAN DEFAULT FALSE,
  transfer_group_id TEXT -- To link legs of a single journey
);

-- Tables for specific API endpoints
CREATE TABLE realtime_arrivals (
  arrival_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  station_id BIGINT NOT NULL REFERENCES stations(station_id),
  route_id BIGINT REFERENCES routes(route_id),
  vehicle_id BIGINT REFERENCES vehicles(vehicle_id),
  estimated_arrival_time TIMESTAMP NOT NULL,
  actual_arrival_time TIMESTAMP,
  status TEXT, -- e.g., 'EXPECTED', 'ARRIVED', 'DELAYED', 'CANCELLED'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- When this prediction was generated/updated
);

CREATE TABLE route_current_location (
  location_update_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  route_id BIGINT NOT NULL REFERENCES routes(route_id),
  vehicle_id BIGINT REFERENCES vehicles(vehicle_id),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  speed DOUBLE PRECISION, -- Optional
  "timestamp" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE alerts (
  alert_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  message TEXT NOT NULL,
  severity TEXT NOT NULL, -- e.g., 'INFO', 'WARNING', 'CRITICAL'
  alert_type TEXT, -- e.g., 'STATION_ISSUE', 'ROUTE_DELAY', 'SYSTEM_WIDE'
  start_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  end_timestamp TIMESTAMP,
  station_id BIGINT REFERENCES stations(station_id), -- If alert is station-specific
  route_id BIGINT REFERENCES routes(route_id) -- If alert is route-specific
);

CREATE TABLE station_destinations ( -- For /stations/top-destinations endpoint
  destination_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  origin_station_id BIGINT NOT NULL REFERENCES stations(station_id),
  final_destination_station_id BIGINT NOT NULL REFERENCES stations(station_id), -- The actual end station of a user's journey starting at origin
  trip_count INTEGER DEFAULT 0,
  aggregation_period TEXT NOT NULL, -- e.g., 'DAILY_2024-05-30', 'WEEKLY_2024-W22', 'MONTHLY_2024-05'
  PRIMARY KEY (origin_station_id, final_destination_station_id, aggregation_period) -- Ensuring uniqueness for aggregation
);

-- Optional but recommended for realism
CREATE TABLE drivers (
  driver_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  employee_id TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  concessionaire_id BIGINT REFERENCES concessionaires(concessionaire_id),
  hire_date DATE,
  license_number TEXT UNIQUE,
  license_expiry_date DATE,
  status TEXT DEFAULT 'active' -- e.g., active, on_leave, inactive
);

CREATE TABLE depots (
  depot_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name TEXT UNIQUE NOT NULL,
  address TEXT,
  depot_type TEXT NOT NULL, -- 'TALLER', 'TRANSITORIO', 'ELECTRICO', 'BAJAS_EMISIONES'
  capacity_vehicles INTEGER,
  location_id BIGINT REFERENCES locations(location_id),
  concessionaire_id BIGINT REFERENCES concessionaires(concessionaire_id) -- If exclusively used by one
);

ALTER TABLE vehicles ADD COLUMN current_depot_id BIGINT REFERENCES depots(depot_id);
ALTER TABLE trips ADD COLUMN driver_id BIGINT REFERENCES drivers(driver_id);