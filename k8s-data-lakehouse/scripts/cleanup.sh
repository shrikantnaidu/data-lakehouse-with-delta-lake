#!/bin/bash

set -e

echo "Cleaning up Data Lakehouse deployment..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

echo "Deleting all resources in data-lakehouse namespace..."
kubectl delete namespace data-lakehouse --ignore-not-found=true

echo "Waiting for namespace deletion..."
while kubectl get namespace data-lakehouse &> /dev/null; do
    echo "  Waiting for namespace to be deleted..."
    sleep 5
done

echo ""
echo "Cleanup completed!"
echo ""
echo "To also remove persistent volumes (WARNING: This will delete all data):"
echo "  kubectl delete pv minio-pv jupyter-pv --ignore-not-found=true"