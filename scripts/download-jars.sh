#!/bin/bash

# Create jars directory if it doesn't exist
mkdir -p ./jars

# Download JARs only if they don't exist (for caching)
cd ./jars

echo "Cleaning up old JARs..."
rm -f *2.2.0.jar *2.4.0.jar *.1 aws-java-sdk-1.12.367.jar s3-2.18.41.jar delta-core_2.12-*.jar

echo "Downloading required JARs..."

# Function to download if not exists
download_if_not_exists() {
    local url=$1
    local filename=$2
    
    if [ ! -f "$filename" ]; then
        echo "Downloading $filename..."
        curl -L -o "$filename" "$url"
    else
        echo "$filename already exists, skipping..."
    fi
}

# Download all required JARs
download_if_not_exists "https://repo1.maven.org/maven2/software/amazon/awssdk/s3/2.20.40/s3-2.20.40.jar" "s3-2.20.40.jar" &
download_if_not_exists "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.12.507/aws-java-sdk-1.12.507.jar" "aws-java-sdk-1.12.507.jar" &
download_if_not_exists "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.1026/aws-java-sdk-bundle-1.11.1026.jar" "aws-java-sdk-bundle-1.11.1026.jar" &
download_if_not_exists "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.2/hadoop-aws-3.3.2.jar" "hadoop-aws-3.3.2.jar" &
download_if_not_exists "https://repo1.maven.org/maven2/io/delta/delta-spark_2.12/3.0.0/delta-spark_2.12-3.0.0.jar" "delta-spark_2.12-3.0.0.jar" &
download_if_not_exists "https://repo1.maven.org/maven2/io/delta/delta-storage/3.0.0/delta-storage-3.0.0.jar" "delta-storage-3.0.0.jar" &
download_if_not_exists "https://repo1.maven.org/maven2/org/postgresql/postgresql/42.6.0/postgresql-42.6.0.jar" "postgresql-42.6.0.jar" &

wait

echo "All JARs downloaded successfully!"