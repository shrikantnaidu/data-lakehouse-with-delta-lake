# Data Lakehouse on Kubernetes

This repository contains a Kubernetes deployment for a data lakehouse architecture using Apache Spark, Delta Lake, and MinIO (S3-compatible object storage). This is the Kubernetes version of the original Docker Compose setup.

## 🏗️ Architecture

The deployment consists of the following components:

- **Apache Spark 3.4.0** - Distributed computing engine
  - 1 Master node
  - 2 Worker nodes (scalable)
- **Delta Lake 2.4.0** - ACID transactions and time travel for data lakes
- **MinIO** - S3-compatible object storage
- **Jupyter Notebook** - Interactive development environment with PySpark

## 📋 Prerequisites

- Kubernetes cluster (local or remote)
- `kubectl` configured to access your cluster
- Docker (for building custom images)
- `kustomize` (optional, for advanced deployment options)

### Local Development Setup

For local development, you can use:
- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [k3s](https://k3s.io/)
- Docker Desktop with Kubernetes enabled

## 🚀 Quick Start

### 1. Build Docker Images

```bash
# Build custom Docker images
make build
```

### 2. Deploy to Kubernetes

```bash
# Deploy all components
make deploy
```

### 3. Access Services

Once deployed, you can access the services using NodePort:

- **Jupyter Notebook**: http://localhost:30888 (token: `777`)
- **Spark Master UI**: http://localhost:30080
- **MinIO Console**: http://localhost:30901 (user: `minio`, password: `minio123`)
- **MinIO API**: http://localhost:30900

## 📁 Project Structure

```
k8s-data-lakehouse/
├── manifests/           # Kubernetes manifests
│   ├── 01-namespace.yaml
│   ├── 02-configmaps.yaml
│   ├── 03-services.yaml
│   ├── 04-persistent-volumes.yaml
│   ├── 05-spark-master.yaml
│   ├── 06-spark-workers.yaml
│   ├── 07-minio.yaml
│   ├── 08-jupyter.yaml
│   └── 09-ingress.yaml
├── docker/              # Docker configurations
│   ├── spark/
│   │   └── Dockerfile
│   └── notebooks/
│       └── Dockerfile
├── config/              # Configuration files
│   ├── spark-defaults.conf
│   └── spark-defaults-notebook.conf
├── scripts/             # Deployment scripts
│   ├── build-images.sh
│   ├── deploy.sh
│   ├── cleanup.sh
│   └── scale.sh
├── kustomization.yaml   # Kustomize configuration
├── Makefile            # Build and deployment targets
└── README.md
```

## 🛠️ Management Commands

### Build and Deploy
```bash
make build      # Build Docker images
make deploy     # Deploy to Kubernetes
make status     # Check deployment status
```

### Scaling
```bash
make scale WORKERS=3    # Scale to 3 Spark workers
./scripts/scale.sh -w 5 # Alternative scaling method
```

### Monitoring and Debugging
```bash
make logs       # View logs from all services
make status     # Check pod and service status

# Check specific component logs
kubectl logs -n data-lakehouse deployment/spark-master
kubectl logs -n data-lakehouse deployment/jupyter-notebook
kubectl logs -n data-lakehouse deployment/minio
```

### Cleanup
```bash
make clean      # Remove all components
```

## 🔧 Advanced Configuration

### Using Ingress (Alternative to NodePort)

If you have an Ingress controller installed, you can use the provided Ingress resources:

1. Update `/etc/hosts` (or equivalent):
```
127.0.0.1 jupyter.local
127.0.0.1 spark-master.local
127.0.0.1 minio.local
127.0.0.1 minio-api.local
```

2. Access services via:
- Jupyter: http://jupyter.local
- Spark Master: http://spark-master.local
- MinIO Console: http://minio.local
- MinIO API: http://minio-api.local

### Persistent Storage

The deployment uses local persistent volumes. For production:

1. Update `manifests/04-persistent-volumes.yaml` to use your storage class
2. Replace `storageClassName: local-storage` with your preferred storage class

### Resource Limits

Adjust resource requests and limits in the deployment files:
- Spark Master: `manifests/05-spark-master.yaml`
- Spark Workers: `manifests/06-spark-workers.yaml`
- Jupyter: `manifests/08-jupyter.yaml`
- MinIO: `manifests/07-minio.yaml`

## 🧪 Usage Examples

### 1. Connect to Spark from Jupyter

In a Jupyter notebook cell:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("DataLakehouse") \
    .config("spark.master", "spark://spark-master-service:7077") \
    .getOrCreate()

# Test Spark connection
df = spark.range(10)
df.show()
```

### 2. Using Delta Lake

```python
# Write data to Delta Lake
df.write.format("delta").mode("overwrite").save("s3a://warehouse/delta-table")

# Read from Delta Lake
delta_df = spark.read.format("delta").load("s3a://warehouse/delta-table")
delta_df.show()
```

### 3. S3/MinIO Operations

```python
# Configure Spark for S3/MinIO access (already configured via spark-defaults.conf)
df = spark.read.json("s3a://warehouse/data.json")
df.write.mode("overwrite").json("s3a://warehouse/output")
```

## 🔍 Troubleshooting

### Common Issues

1. **Images not found**: Ensure you've built the custom images with `make build`

2. **Persistent volumes not binding**: 
   - Check if the host paths exist: `/tmp/minio-data`, `/tmp/jupyter-notebooks`
   - Ensure your cluster supports local persistent volumes

3. **Services not accessible**:
   - Check if NodePort services are running: `kubectl get svc -n data-lakehouse`
   - Verify firewall settings for ports 30040, 30080, 30888, 30900, 30901

4. **Spark workers not connecting**:
   - Check network policies
   - Verify Spark master service is running
   - Check worker logs: `kubectl logs -n data-lakehouse deployment/spark-worker`

### Debugging Commands

```bash
# Check all resources
kubectl get all -n data-lakehouse

# Describe problematic pods
kubectl describe pod <pod-name> -n data-lakehouse

# Check events
kubectl get events -n data-lakehouse --sort-by='.lastTimestamp'

# Port forward for direct access
kubectl port-forward -n data-lakehouse svc/jupyter-service 8888:8888
kubectl port-forward -n data-lakehouse svc/spark-master-service 8080:8080
kubectl port-forward -n data-lakehouse svc/minio-service 9000:9000 9001:9001
```

## 🔒 Security Considerations

For production deployments:

1. **Change default credentials** in MinIO configuration
2. **Enable authentication** for Spark and Jupyter
3. **Use secrets** instead of hardcoded passwords
4. **Configure network policies** to restrict traffic
5. **Enable TLS/SSL** for all services
6. **Use RBAC** for service accounts

## 📦 Image Registry

To use a custom registry:

1. Build and tag images:
```bash
docker build -t your-registry.com/data-lakehouse/spark:latest -f docker/spark/Dockerfile docker/spark/
docker build -t your-registry.com/data-lakehouse/jupyter:latest -f docker/notebooks/Dockerfile docker/notebooks/
```

2. Push to registry:
```bash
docker push your-registry.com/data-lakehouse/spark:latest
docker push your-registry.com/data-lakehouse/jupyter:latest
```

3. Update `kustomization.yaml` with your registry URLs

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## 📄 License

This project maintains the same license as the original repository.

## 📚 Additional Resources

- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [Delta Lake Documentation](https://docs.delta.io/latest/index.html)
- [MinIO Documentation](https://min.io/docs/minio/kubernetes/upstream/index.html)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)