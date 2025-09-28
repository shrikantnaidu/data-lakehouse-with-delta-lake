#!/bin/bash

set -e

echo "Building Docker images for Data Lakehouse on Kubernetes..."

# Build Spark Master/Worker image
echo "Building Spark image..."
docker build -t data-lakehouse/spark:latest -f docker/spark/Dockerfile docker/spark/

# Build Jupyter Notebook image
echo "Building Jupyter Notebook image..."
docker build -t data-lakehouse/jupyter:latest -f docker/notebooks/Dockerfile docker/notebooks/

echo "Docker images built successfully!"
echo "Available images:"
docker images | grep data-lakehouse

echo ""
echo "To push images to a registry, use:"
echo "  docker tag data-lakehouse/spark:latest YOUR_REGISTRY/data-lakehouse/spark:latest"
echo "  docker push YOUR_REGISTRY/data-lakehouse/spark:latest"
echo "  docker tag data-lakehouse/jupyter:latest YOUR_REGISTRY/data-lakehouse/jupyter:latest"
echo "  docker push YOUR_REGISTRY/data-lakehouse/jupyter:latest"