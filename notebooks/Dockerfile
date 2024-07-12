FROM jupyter/all-spark-notebook:python-3.9

USER root 

# Install Spark 3.4.0
RUN curl -O https://archive.apache.org/dist/spark/spark-3.4.0/spark-3.4.0-bin-hadoop3.tgz \
    && tar zxvf spark-3.4.0-bin-hadoop3.tgz \
    && rm -rf spark-3.4.0-bin-hadoop3.tgz \
    && mv spark-3.4.0-bin-hadoop3/ /usr/local/ \
    && rm -rf /usr/local/spark \
    && ln -s /usr/local/spark-3.4.0-bin-hadoop3 /usr/local/spark

# Download the latest versions of the required jars
RUN curl -O https://repo1.maven.org/maven2/software/amazon/awssdk/s3/2.20.40/s3-2.20.40.jar \
    && curl -O https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.12.507/aws-java-sdk-1.12.507.jar \
    && curl -O https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.1026/aws-java-sdk-bundle-1.11.1026.jar \
    && curl -O https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.4.0/delta-core_2.12-2.4.0.jar \
    && curl -O https://repo1.maven.org/maven2/io/delta/delta-storage/2.4.0/delta-storage-2.4.0.jar \
    && curl -O https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.2/hadoop-aws-3.3.2.jar \
    && mv s3-2.20.40.jar /usr/local/spark/jars \
    && mv aws-java-sdk-1.12.507.jar /usr/local/spark/jars \
    && mv aws-java-sdk-bundle-1.11.1026.jar /usr/local/spark/jars \
    && mv delta-core_2.12-2.4.0.jar /usr/local/spark/jars \
    && mv delta-storage-2.4.0.jar /usr/local/spark/jars \
    && mv hadoop-aws-3.3.2.jar /usr/local/spark/jars

# Set up JupyterLab to be accessible without a token
ENV JUPYTER_TOKEN=""

# Set Python environment variables
ENV PYSPARK_PYTHON=/opt/bitnami/python/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/opt/bitnami/python/bin/python3

# Clean up to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Switch back to jovyan user
USER jovyan
