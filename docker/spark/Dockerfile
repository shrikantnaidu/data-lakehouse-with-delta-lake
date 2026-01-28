FROM apache/spark:3.5.0

USER root

# Copy pre-downloaded JARs (much faster than downloading during build)
COPY jars/*.jar /opt/spark/jars/

USER 185
