# Public Transport Recharge and Travel System

This project contains the design and implementation of a relational database for the Credits and Travel Module of a public transport system. The system enables the management of card recharges and tracking of travel activities for users of the mass transportation network. The primary objective is to improve the user experience by offering an efficient system to log and monitor transactions and travel history.

> **Note:** This project is an academic exercise developed to practice database design concepts and does not reflect the actual infrastructure of a public transport system.

## Relational Diagram

```mermaid
erDiagram
    USUARIOS {
        int usuario_id PK
        string nombre
        string apellido
        string numero_contacto
        string correo_electronico
        string genero
        date fecha_nacimiento
        string direccion_residencia
        string numero_cedula
        string ciudad_nacimiento
        date fecha_registro
    }

    LOCALIDADES {
        int localidad_id PK
        string nombre
    }

    TARJETAS {
        int tarjeta_id PK
        int usuario_id FK
        date fecha_adquisicion
        string estado
        date fecha_actualizacion
    }

    PUNTOS_RECARGA {
        int punto_recarga_id PK
        string direccion
        float latitud
        float longitud
        int localidad_id FK
    }

    TARIFAS {
        int tarifa_id PK
        float valor
        date fecha
    }

    RECARGAS {
        int recarga_id PK
        date fecha
        float monto
        int punto_recarga_id FK
        int tarjeta_id FK
    }

    ESTACIONES {
        int estacion_id PK
        string nombre
        string direccion
        int localidad_id
        float latitud
        float longitud
    }

    RUTAS {
        int ruta_id PK
        int estacion_origen_id FK
        int estacion_destino_id FK
    }

    ESTACIONES_INTERMEDIAS {
        int estacion_id PK "FK"
        int ruta_id PK "FK"
    }

    VIAJES {
        int viaje_id PK
        int estacion_abordaje_id FK
        date fecha
        int tarifa_id FK
        int tarjeta_id FK
    }

    USUARIOS ||--o{ TARJETAS : ""
    TARJETAS ||--o{ RECARGAS : ""
    PUNTOS_RECARGA ||--o{ RECARGAS : ""
    LOCALIDADES ||--o{ PUNTOS_RECARGA : ""
    LOCALIDADES ||--o{ ESTACIONES : ""
    ESTACIONES ||--o{ VIAJES : ""
    TARJETAS ||--o{ VIAJES : ""
    TARIFAS ||--o{ VIAJES : ""
    ESTACIONES ||--|{ RUTAS : ""
    ESTACIONES ||--|{ RUTAS : ""
    RUTAS ||--o{ ESTACIONES_INTERMEDIAS : ""
    ESTACIONES ||--o{ ESTACIONES_INTERMEDIAS : ""
```

## Project Description

### Context

A public transportation company in Bogotá is looking to modernize its card recharge and travel tracking system. This module enables:

- User registration and card management.
- Management of authorized recharge points.
- Logging of card balance top-ups.
- Monitoring of stations, routes, and trips.

The system ensures traceability of recharges and user trips, maintaining a precise history of each transaction to allow queries and audits.

### Core Features

**Users:**

- User and card registration.
- Management of card balances.

**Authorized Recharge Points:**

- Registration of recharge points with geographic data (latitude, longitude) and locality.

**Recharges:**

- Each recharge is logged with date, amount, and location.
- Historical tariffs allow accurate queries based on date.

**Stations and Routes:**

- Station registration with geographic data.
- Route definition with origin, destination, and intermediate stations.

**Trips:**

- Logs each trip, including boarding station and automatic balance deduction.

## Fake Data Generator

The following notebook generates synthetic data for the schema. Data may include inconsistencies. Feel free to modify and adapt the notebook for your own datasets:

[Google Colab Notebook](https://colab.research.google.com/drive/1P0vnmkWPp9hxLaNTr7Ads2Osryb3bWIV?usp=sharing)
