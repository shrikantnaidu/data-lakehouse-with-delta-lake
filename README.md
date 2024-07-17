# Data Lakehouse with Delta Lake

This repository contains a setup for a data lakehouse architecture using Apache Spark, Delta Lake, and MinIO (S3-compatible object storage).

## Components

- Apache Spark 3.4.0
- Delta Lake 2.4.0
- MinIO (S3-compatible object storage)
- Jupyter Notebook with PySpark

## Setup

1. Build the Docker images:
```
make build
```

2. Start the services:
```
make up
```

3. Access Jupyter Notebook:
- URL: http://localhost:8888
- No token required (JUPYTER_TOKEN is set to empty)

4. Access Spark UI:
- Master: http://localhost:8080/
- Jobs: http://localhost:4040/jobs/

5. Access MinIO UI:
- URL: http://localhost:9000/
- Credentials: minio / minio123

## Usage

1. Use the Jupyter Notebook interface to create and run PySpark notebooks.
2. Utilize Delta Lake for ACID transactions and time travel capabilities.
3. Store and retrieve data from MinIO using the S3A filesystem.

## Configuration

- Spark configuration is available in `notebooks/spark-defaults.conf`
- Docker services are defined in `docker-compose.yml`

## Additional Information

- The setup includes necessary JAR files for S3 connectivity and Delta Lake integration.
- PySpark and Delta Spark libraries are pre-installed in the Jupyter environment.

## Stopping the Services

To stop and remove the containers:
```
make down
```

## Restarting the Services

To restart the services:
```
make down
```