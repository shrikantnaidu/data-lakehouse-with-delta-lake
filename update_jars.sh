#!/bin/bash

mkdir -p jars/ && cd jars/
wget https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.2.0/delta-core_2.12-2.2.0.jar
wget https://repo1.maven.org/maven2/io/delta/delta-storage/2.2.0/delta-storage-2.2.0.jar
wget https://repo1.maven.org/maven2/software/amazon/awssdk/s3/2.18.41/s3-2.18.41.jar
wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.12.367/aws-java-sdk-1.12.367.jar

docker cp delta-core_2.12-2.2.0.jar spark-master:/opt/bitnami/spark/jars
docker cp delta-storage-2.2.0.jar spark-master:/opt/bitnami/spark/jars
docker cp s3-2.18.41.jar spark-master:/opt/bitnami/spark/jars
docker cp aws-java-sdk-1.12.367.jar spark-master:/opt/bitnami/spark/jars
docker-compose restart spark-master
