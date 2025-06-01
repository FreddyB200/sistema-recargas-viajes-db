# Deployment Guide

This guide covers two main use cases:
1. **API/Database Users:** You want to quickly deploy the database (with pre-generated data) to use it as a backend for the API or for testing/analytics.
2. **Data Experimenters:** You want to generate your own synthetic data, modify the schema, or experiment with the data generator (Python/Faker/Jupyter).

---

## 1. Quick Start: Deploy the Database (Recommended for API Users)

### Prerequisites
- Docker
- Docker Compose
- Git

If you do not have these tools, see the [Full Setup for Data Experimenters](#2-full-setup-for-data-experimenters) below for installation instructions.

### a) Clone the Repository
```bash
git clone https://github.com/FreddyB200/travel-recharge-database.git
cd travel-recharge-database
```

### b) Configure Environment Variables
Create a `.env` file in the project root with the following content (edit as needed):
```ini
POSTGRES_DB=travel-recharge-database
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
POSTGRES_LISTEN_PORT=5432
```

### c) Start the Database
```bash
docker-compose up -d
```
This will start a PostgreSQL container with the schema and pre-generated data.

### d) Access the Database (Optional)
You can connect using `psql`, pgAdmin, or any PostgreSQL client. To access via terminal:
```bash
docker exec -it db bash
psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
```

---

## 2. Full Setup for Data Experimenters (Generate or Modify Data)

If you want to generate your own data, modify the schema, or experiment with the data generator, follow these steps **after cloning the repository**:

### a) Install Python 3.9+, pip, and venv
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

### b) Create and Activate a Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
```

### c) Install Python Dependencies
```bash
pip install --upgrade pip
pip install jupyter faker pandas
```

### d) Run the Data Generator Notebook
Start Jupyter Notebook:
```bash
jupyter notebook
```
Open `db/data/data_generation.ipynb` in the Jupyter web interface and run the cells to generate new SQL scripts. You can modify the notebook to customize the generated data.

- Generated SQL scripts will appear in `db/data/generated_sql_scripts/`.
- You can then restart the database or reload the data as needed.

---

## 3. Notes
- If you only want to use the database with the API, you do **not** need to run the Python/Jupyter steps.
- If you want to experiment with data, you can always regenerate the SQL scripts and reload the database.
- If you have Docker permission issues, make sure your user is in the `docker` group and restart your session.

---
