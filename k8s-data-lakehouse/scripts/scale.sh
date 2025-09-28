#!/bin/bash

set -e

# Default values
WORKERS=2
NAMESPACE="data-lakehouse"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--workers)
            WORKERS="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Scale Spark workers in the Data Lakehouse cluster"
            echo ""
            echo "Options:"
            echo "  -w, --workers NUM     Number of Spark workers (default: 2)"
            echo "  -n, --namespace NAME  Kubernetes namespace (default: data-lakehouse)"
            echo "  -h, --help           Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

echo "Scaling Spark workers to $WORKERS replicas in namespace $NAMESPACE..."

kubectl scale deployment spark-worker --replicas=$WORKERS -n $NAMESPACE

echo "Scaling completed!"
echo ""
echo "Current worker status:"
kubectl get pods -n $NAMESPACE -l app=spark-worker