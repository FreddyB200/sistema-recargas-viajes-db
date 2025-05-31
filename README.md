```mermaid
erDiagram
    USERS {
        int user_id PK
        string first_name
        string last_name
        string contact_number
        string email
        string gender
        date date_of_birth
        string residential_address
        string id_number
        string city_of_birth
        date registration_date
    }

    LOCATIONS {
        int location_id PK
        string name
    }

    CARDS {
        int card_id PK
        int user_id FK
        date acquisition_date
        string status
        date update_date
    }

    RECHARGE_POINTS {
        int recharge_point_id PK
        string address
        float latitude
        float longitude
        int location_id FK
    }

    FARES {
        int fare_id PK
        float value
        date date
    }

    RECHARGES {
        int recharge_id PK
        date date
        float amount
        int recharge_point_id FK
        int card_id FK
    }

    STATIONS {
        int station_id PK
        string name
        string address
        int location_id
        float latitude
        float longitude
    }

    ROUTES {
        int route_id PK
        int origin_station_id FK
        int destination_station_id FK
    }

    INTERMEDIATE_STATIONS {
        int station_id PK "FK"
        int route_id PK "FK"
    }

    TRIPS {
        int trip_id PK
        int boarding_station_id FK
        date date
        int fare_id FK
        int card_id FK
    }

    USERS ||--o{ CARDS : ""
    CARDS ||--o{ RECHARGES : ""
    RECHARGE_POINTS ||--o{ RECHARGES : ""
    LOCATIONS ||--o{ RECHARGE_POINTS : ""
    LOCATIONS ||--o{ STATIONS : ""
    STATIONS ||--o{ TRIPS : ""
    CARDS ||--o{ TRIPS : ""
    FARES ||--o{ TRIPS : ""
    STATIONS ||--|{ ROUTES : ""
    STATIONS ||--|{ ROUTES : ""
    ROUTES ||--o{ INTERMEDIATE_STATIONS : ""
    STATIONS ||--o{ INTERMEDIATE_STATIONS : ""
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

## Credits

This repository is a fork of the original project created by my database professor, [Cristian Fernando](https://github.com/cfernandom). The original repository served as the foundation for this project, and I have made improvements and modifications to adapt it to my needs.

## Fake Data Generator

The following notebook generates synthetic data for the schema. Data may include inconsistencies. Feel free to modify and adapt the notebook for your own datasets:

[Google Colab Notebook](https://colab.research.google.com/drive/1P0vnmkWPp9hxLaNTr7Ads2Osryb3bWIV?usp=sharing)
