FROM docker.io/bitnami/spark:3.4.0

USER root

# Install prerequisites
RUN apt-get update && apt-get install -y curl

# Download the latest versions of the required jars
RUN curl -O https://repo1.maven.org/maven2/software/amazon/awssdk/s3/2.20.40/s3-2.20.40.jar \
    && curl -O https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.12.507/aws-java-sdk-1.12.507.jar \
    && curl -O https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.4.0/delta-core_2.12-2.4.0.jar \
    && curl -O https://repo1.maven.org/maven2/io/delta/delta-storage/2.4.0/delta-storage-2.4.0.jar \
    && mv s3-2.20.40.jar /opt/bitnami/spark/jars \
    && mv aws-java-sdk-1.12.507.jar /opt/bitnami/spark/jars \
    && mv delta-core_2.12-2.4.0.jar /opt/bitnami/spark/jars \
    && mv delta-storage-2.4.0.jar /opt/bitnami/spark/jars
