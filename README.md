```mermaid
erDiagram
    USERS {
        BIGINT user_id PK
        TEXT first_name
        TEXT last_name
        TEXT contact_number
        TEXT email UK
        TEXT gender
        DATE date_of_birth
        TEXT residential_address
        TEXT id_number UK
        TEXT city_of_birth
        DATE registration_date
    }

    LOCATIONS {
        BIGINT location_id PK
        TEXT name UK
        TEXT description
    }

    CONCESSIONAIRES {
        BIGINT concessionaire_id PK
        TEXT name UK
        BOOLEAN operates_troncal
        BOOLEAN operates_zonal_uce
        BOOLEAN operates_zonal_alimentacion
        BOOLEAN operates_cable
    }

    VEHICLES {
        BIGINT vehicle_id PK
        TEXT license_plate UK
        TEXT vehicle_type
        INTEGER capacity
        TEXT technology
        INTEGER model_year
        BIGINT concessionaire_id FK
        TEXT status
        BIGINT current_depot_id FK
    }

    STATIONS {
        BIGINT station_id PK
        TEXT name
        TEXT station_code UK
        TEXT station_type
        TEXT address
        BIGINT location_id FK
        DOUBLE_PRECISION latitude
        DOUBLE_PRECISION longitude
        BOOLEAN has_cycle_parking
        INTEGER cycle_parking_spots
        BOOLEAN is_active
    }

    ROUTES {
        BIGINT route_id PK
        TEXT route_code UK
        TEXT route_name
        TEXT route_type
        BIGINT origin_station_id FK
        BIGINT destination_station_id FK
        BIGINT concessionaire_id FK
        BOOLEAN is_active
    }

    INTERMEDIATE_STATIONS {
        BIGINT intermediate_station_id PK
        BIGINT route_id FK
        BIGINT station_id FK
        INTEGER sequence_order
    }

    CARDS {
        BIGINT card_id PK
        TEXT card_number UK
        BIGINT user_id FK
        DATE acquisition_date
        TEXT status
        DOUBLE_PRECISION balance
        TIMESTAMP last_used_date
        DATE update_date
    }

    RECHARGE_POINTS {
        BIGINT recharge_point_id PK
        TEXT name
        TEXT address
        DOUBLE_PRECISION latitude
        DOUBLE_PRECISION longitude
        BIGINT location_id FK
        TEXT operator
    }

    FARES {
        BIGINT fare_id PK
        TEXT fare_type
        DOUBLE_PRECISION value
        DATE start_date
        DATE end_date
        TEXT description
    }

    RECHARGES {
        BIGINT recharge_id PK
        BIGINT card_id FK
        BIGINT recharge_point_id FK
        DOUBLE_PRECISION amount
        TIMESTAMP recharge_timestamp
        TEXT transaction_id UK
    }

    TRIPS {
        BIGINT trip_id PK
        BIGINT card_id FK
        BIGINT vehicle_id FK
        BIGINT route_id FK
        BIGINT driver_id FK
        BIGINT boarding_station_id FK
        BIGINT disembarking_station_id FK
        TIMESTAMP boarding_time
        TIMESTAMP disembarking_time
        BIGINT fare_id FK
        BOOLEAN is_transfer
        TEXT transfer_group_id
    }

    REALTIME_ARRIVALS {
        BIGINT arrival_id PK
        BIGINT station_id FK
        BIGINT route_id FK
        BIGINT vehicle_id FK
        TIMESTAMP estimated_arrival_time
        TIMESTAMP actual_arrival_time
        TEXT status
        TIMESTAMP created_at
    }

    ROUTE_CURRENT_LOCATION {
        BIGINT location_update_id PK
        BIGINT route_id FK
        BIGINT vehicle_id FK
        DOUBLE_PRECISION latitude
        DOUBLE_PRECISION longitude
        DOUBLE_PRECISION speed
        TIMESTAMP timestamp
    }

    ALERTS {
        BIGINT alert_id PK
        TEXT message
        TEXT severity
        TEXT alert_type
        TIMESTAMP start_timestamp
        TIMESTAMP end_timestamp
        BIGINT station_id FK
        BIGINT route_id FK
    }

    STATION_DESTINATIONS {
        BIGINT destination_id PK
        BIGINT origin_station_id FK
        BIGINT final_destination_station_id FK
        INTEGER trip_count
        TEXT aggregation_period
    }

    DRIVERS {
        BIGINT driver_id PK
        TEXT employee_id UK
        TEXT first_name
        TEXT last_name
        BIGINT concessionaire_id FK
        DATE hire_date
        TEXT license_number UK
        TEXT license_expiry_date
        TEXT status
    }

    DEPOTS {
        BIGINT depot_id PK
        TEXT name UK
        TEXT address
        TEXT depot_type
        INTEGER capacity_vehicles
        BIGINT location_id FK
        BIGINT concessionaire_id FK
    }

    USERS ||--o{ CARDS : "has"
    CARDS ||--o{ RECHARGES : "receives"
    RECHARGE_POINTS ||--o{ RECHARGES : "done_at"
    LOCATIONS ||--o{ RECHARGE_POINTS : "located_in"
    LOCATIONS ||--o{ STATIONS : "located_in"
    LOCATIONS ||--o{ DEPOTS : "located_in"

    CONCESSIONAIRES ||--o{ VEHICLES : "owns"
    CONCESSIONAIRES ||--o{ ROUTES : "operates"
    CONCESSIONAIRES ||--o{ DRIVERS : "employs"
    CONCESSIONAIRES ||--o{ DEPOTS : "uses"

    STATIONS ||--o{ ROUTES : "origin_for"
    STATIONS ||--o{ ROUTES : "destination_for"
    STATIONS ||--o{ INTERMEDIATE_STATIONS : "is_part_of_route"
    STATIONS ||--o{ TRIPS : "boarding_at"
    STATIONS ||--o{ TRIPS : "disembarking_at"
    STATIONS ||--o{ REALTIME_ARRIVALS : "arrivals_for"
    STATIONS ||--o{ ALERTS : "alert_for_station"
    STATIONS ||--o{ STATION_DESTINATIONS : "origin_stats"
    STATIONS ||--o{ STATION_DESTINATIONS : "final_stats"

    ROUTES ||--o{ INTERMEDIATE_STATIONS : "has_sequence"
    ROUTES ||--o{ TRIPS : "taken_on"
    ROUTES ||--o{ REALTIME_ARRIVALS : "arrivals_on"
    ROUTES ||--o{ ROUTE_CURRENT_LOCATION : "location_for"
    ROUTES ||--o{ ALERTS : "alert_for_route"

    VEHICLES ||--o{ TRIPS : "used_for"
    VEHICLES ||--o{ REALTIME_ARRIVALS : "vehicle_arriving"
    VEHICLES ||--o{ ROUTE_CURRENT_LOCATION : "current_vehicle"
    DEPOTS ||--o{ VEHICLES : "houses"

    DRIVERS ||--o{ TRIPS : "drives_for"

    CARDS ||--o{ TRIPS : "used_by"
    FARES ||--o{ TRIPS : "applies_to"

```

## Project Description

### Context

A public transportation company in Bogotá is looking to modernize its card recharge and travel tracking system. This module enables:

- User registration and card management.
- Management of authorized recharge points.
- Logging of card balance top-ups.
- Monitoring of stations, routes, and trips.
---
The system ensures traceability of recharges and user trips, maintaining a precise history of each transaction to allow queries and audits.
---
### Core Features
---
**Users:**

- User and card registration.
- Management of card balances.

--- 

**Authorized Recharge Points:**

- Registration of recharge points with geographic data (latitude, longitude) and locality.
---
**Recharges:**

- Each recharge is logged with date, amount, and location.
- Historical tariffs allow accurate queries based on date.
---
**Stations and Routes:**

- Station registration with geographic data.
- Route definition with origin, destination, and intermediate stations.
---
**Trips:**

- Logs each trip, including boarding station and automatic balance deduction.
---
## Deployment Guide

For instructions on how to deploy this project, please refer to the [Deployment Guide](DEPLOYMENT.md).

## API Repository

The API for this database is available at the following repository:
[Travel Recharge API](https://github.com/FreddyB200/travel-recharge-api)


## Credits

This repository is a fork of the original project created by my database professor, [Cristian Fernando](https://github.com/cfernandom). The original repository served as the foundation for this project, and I have made improvements and modifications to adapt it to my needs.

## Fake Data Generator

The following notebook generates synthetic data for the schema. Data may include inconsistencies. Feel free to modify and adapt the notebook for your own datasets:

[Google Colab Notebook](https://colab.research.google.com/drive/1P0vnmkWPp9hxLaNTr7Ads2Osryb3bWIV?usp=sharing)
