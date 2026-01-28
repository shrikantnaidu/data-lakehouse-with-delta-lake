FROM jupyter/all-spark-notebook:python-3.9

USER root 

# Install Spark 3.5.0 (matching the cluster version)
RUN curl -L https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz | tar -xz -C /usr/local/ && \
    rm -rf /usr/local/spark && \
    ln -s /usr/local/spark-3.5.0-bin-hadoop3 /usr/local/spark

# Copy pre-downloaded JARs (much faster than downloading during build)
COPY jars/*.jar /usr/local/spark/jars/

# Install Python packages - all essential components pre-installed
RUN pip install --no-cache-dir \
    pyspark==3.5.0 \
    delta-spark==3.0.0 \
    minio \
    pandas \
    pyarrow \
    fastparquet \
    boto3 \
    s3fs \
    psycopg2-binary \
    sqlalchemy && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variables for Delta Lake
ENV DELTA_SPARK_VERSION=3.0.0
ENV PYSPARK_PYTHON=/opt/conda/bin/python
ENV PYSPARK_DRIVER_PYTHON=/opt/conda/bin/python

USER jovyan