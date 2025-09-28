#!/bin/bash

set -e

echo "Deploying Data Lakehouse to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if kustomize is available
if ! command -v kustomize &> /dev/null; then
    echo "Warning: kustomize is not installed. Using kubectl apply -k instead."
    KUSTOMIZE_CMD="kubectl apply -k"
else
    KUSTOMIZE_CMD="kustomize build . | kubectl apply -f -"
fi

# Create namespace if it doesn't exist
echo "Creating namespace..."
kubectl create namespace data-lakehouse --dry-run=client -o yaml | kubectl apply -f -

# Apply all manifests using kustomize
echo "Applying Kubernetes manifests..."
if [[ "$KUSTOMIZE_CMD" == "kubectl apply -k" ]]; then
    kubectl apply -k .
else
    kustomize build . | kubectl apply -f -
fi

echo ""
echo "Deployment completed!"
echo ""
echo "Checking pod status..."
kubectl get pods -n data-lakehouse

echo ""
echo "Services:"
kubectl get services -n data-lakehouse

echo ""
echo "Access URLs (assuming NodePort services):"
echo "  Jupyter Notebook: http://localhost:30888 (token: 777)"
echo "  Spark Master UI:  http://localhost:30080"
echo "  MinIO Console:    http://localhost:30901 (user: minio, password: minio123)"
echo "  MinIO API:        http://localhost:30900"

echo ""
echo "To check logs:"
echo "  kubectl logs -n data-lakehouse deployment/spark-master"
echo "  kubectl logs -n data-lakehouse deployment/jupyter-notebook"
echo "  kubectl logs -n data-lakehouse deployment/minio"