create table users (
  user_id bigint primary key generated always as identity
  first_name text,
  last_name text,
  contact_number text,
  email text,
  gender text,
  date_of_birth date,
  residential_address text,
  id_number text,
  city_of_birth text,
  registration_date date
);

create table locations (
  location_id bigint primary key generated always as identity,
  name text
);

create table cards (
  card_id bigint primary key generated always as identity,
  user_id bigint references users (user_id),
  acquisition_date date,
  status text,
  update_date date
);

create table recharge_points (
  recharge_point_id bigint primary key generated always as identity,
  address text,
  latitude double precision,
  longitude double precision,
  location_id bigint references locations (location_id)
);

create table fares (
  fare_id bigint primary key generated always as identity,
  value double precision,
  date date
);

create table recharges (
  recharge_id bigint primary key generated always as identity,
  date date,
  amount double precision,
  recharge_point_id bigint references recharge_points (recharge_point_id),
  card_id bigint references cards (card_id)
);

create table stations (
  station_id bigint primary key generated always as identity,
  name text,
  address text,
  location_id bigint references locations (location_id),
  latitude double precision,
  longitude double precision
);

create table routes (
  route_id bigint primary key generated always as identity,
  origin_station_id bigint references stations (station_id),
  destination_station_id bigint references stations (station_id)
);

create table intermediate_stations (
  station_id bigint references stations (station_id),
  route_id bigint references routes (route_id),
  primary key (station_id, route_id)
);

create table trips (
  trip_id bigint primary key generated always as identity,
  boarding_station_id bigint references stations (station_id),
  date date,
  fare_id bigint references fares (fare_id),
  card_id bigint references cards (card_id)
);
