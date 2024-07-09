#!/bin/bash

# Create directory and navigate to it
mkdir -p jars && cd jars

# Download the required JAR files
wget https://repo1.maven.org/maven2/software/amazon/awssdk/s3/2.18.41/s3-2.18.41.jar
wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.12.367/aws-java-sdk-1.12.367.jar
wget https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.2.0/delta-core_2.12-2.2.0.jar
wget https://repo1.maven.org/maven2/io/delta/delta-storage/2.2.0/delta-storage-2.2.0.jar

# Copy the new JAR files to the Docker container
docker cp aws-java-sdk-1.12.367.jar spark-master:/opt/bitnami/spark/jars
docker cp s3-2.18.41.jar spark-master:/opt/bitnami/spark/jars
docker cp delta-core_2.12-2.2.0.jar spark-master:/opt/bitnami/spark/jars
docker cp delta-storage-2.2.0.jar spark-master:/opt/bitnami/spark/jars

# Check that the files are copied
docker exec spark-master ls -la /opt/bitnami/spark/jars | grep aws-java-sdk
docker exec spark-master ls -la /opt/bitnami/spark/jars | grep s3
docker exec spark-master ls -la /opt/bitnami/spark/jars | grep delta

# Restart the Docker container
docker-compose restart spark-master
