# Deployment Guide
## 1. Prerequisites
Before starting, make sure you have the following components installed on your system:

- Docker: To containerize the database.
- Docker Compose: To manage services defined in docker-compose.yml.
- Git: Version control system.

## 2. Local Setup

### Clone the Repository

```bash
git clone https://github.com/FreddyB200/travel-recharge-database.git
cd travel-recharge-database
```

### Configure Environment Variables

Create a .env file in the project root with the following variables (adjust values as needed):

```ini
POSTGRES_DB=travel-recharge-database
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
POSTGRES_LISTEN_PORT=5432

```

### Start Services with Docker Compose

Run the following command to start the PostgreSQL container:


```bash
docker-compose up -d
```

This will create a PostgreSQL container configured according to the environment variables.

### Verify Container Status

Make sure the container is running properly:

```bash
docker ps
```

You should see a container named `db` running.

## 3. Accessing the Database

You can connect to the database using tools like `psql` or graphical clients such as pgAdmin. Below are instructions to access the database using `psql` inside the container:

### Access Database with psql Inside the Container

1. **Get the Container Name or ID**  
   If you don’t remember the container name, list running containers with:

   ```bash
   docker ps
   ```

   Look for the container named `db`.


2. **Open a Terminal Inside the Container**
    Use this command to enter the container:
   
    ```bash
    docker exec -it db bash
    ```

3. **Connect to the Database with psql**
    Once inside the container, run:

    ```bash
    psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
    ```

4. **Exit the Container**
    When done, exit the container shell with:
       
    ```
    exit
    ```
