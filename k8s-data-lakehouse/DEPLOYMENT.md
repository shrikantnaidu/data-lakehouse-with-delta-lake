# Deployment Guide

This guide provides detailed instructions for deploying the Data Lakehouse on various Kubernetes environments.

## Local Development Environments

### minikube

1. Start minikube:
```bash
minikube start --memory=8192 --cpus=4
```

2. Enable required addons:
```bash
minikube addons enable ingress
minikube addons enable storage-provisioner
```

3. Build and deploy:
```bash
# Set Docker environment to use minikube's Docker daemon
eval $(minikube docker-env)

# Build images
make build

# Deploy
make deploy
```

4. Access services:
```bash
# Get minikube IP
minikube ip

# Access via NodePort
curl http://$(minikube ip):30888  # Jupyter
curl http://$(minikube ip):30080  # Spark Master
curl http://$(minikube ip):30901  # MinIO Console
```

### kind (Kubernetes in Docker)

1. Create kind cluster:
```bash
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
  - containerPort: 30888
    hostPort: 30888
    protocol: TCP
  - containerPort: 30900
    hostPort: 30900
    protocol: TCP
  - containerPort: 30901
    hostPort: 30901
    protocol: TCP
EOF
```

2. Load Docker images:
```bash
# Build images
make build

# Load images into kind cluster
kind load docker-image data-lakehouse/spark:latest
kind load docker-image data-lakehouse/jupyter:latest
```

3. Deploy:
```bash
make deploy
```

### k3s

1. Install k3s:
```bash
curl -sfL https://get.k3s.io | sh -
```

2. Configure kubectl:
```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

3. Deploy:
```bash
make build
make deploy
```

## Cloud Environments

### Amazon EKS

1. Create EKS cluster:
```bash
eksctl create cluster --name data-lakehouse --region us-west-2 --nodegroup-name workers --node-type m5.large --nodes 3
```

2. Configure kubectl:
```bash
aws eks update-kubeconfig --region us-west-2 --name data-lakehouse
```

3. Install EBS CSI driver:
```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
```

4. Update storage class in `manifests/04-persistent-volumes.yaml`:
```yaml
storageClassName: gp2  # or gp3
```

5. Push images to ECR and deploy:
```bash
# Build and tag for ECR
docker build -t your-account.dkr.ecr.us-west-2.amazonaws.com/data-lakehouse/spark:latest -f docker/spark/Dockerfile docker/spark/
docker build -t your-account.dkr.ecr.us-west-2.amazonaws.com/data-lakehouse/jupyter:latest -f docker/notebooks/Dockerfile docker/notebooks/

# Push to ECR
docker push your-account.dkr.ecr.us-west-2.amazonaws.com/data-lakehouse/spark:latest
docker push your-account.dkr.ecr.us-west-2.amazonaws.com/data-lakehouse/jupyter:latest

# Update kustomization.yaml with ECR URLs
# Deploy
make deploy
```

### Google GKE

1. Create GKE cluster:
```bash
gcloud container clusters create data-lakehouse \
    --zone us-central1-a \
    --num-nodes 3 \
    --machine-type n1-standard-4
```

2. Configure kubectl:
```bash
gcloud container clusters get-credentials data-lakehouse --zone us-central1-a
```

3. Update storage class in `manifests/04-persistent-volumes.yaml`:
```yaml
storageClassName: standard-rwo
```

4. Push images to GCR and deploy:
```bash
# Tag for GCR
docker tag data-lakehouse/spark:latest gcr.io/your-project/data-lakehouse/spark:latest
docker tag data-lakehouse/jupyter:latest gcr.io/your-project/data-lakehouse/jupyter:latest

# Push to GCR
docker push gcr.io/your-project/data-lakehouse/spark:latest
docker push gcr.io/your-project/data-lakehouse/jupyter:latest

# Update kustomization.yaml with GCR URLs
# Deploy
make deploy
```

### Azure AKS

1. Create AKS cluster:
```bash
az aks create \
    --resource-group myResourceGroup \
    --name data-lakehouse \
    --node-count 3 \
    --node-vm-size Standard_D4s_v3 \
    --enable-addons monitoring \
    --generate-ssh-keys
```

2. Configure kubectl:
```bash
az aks get-credentials --resource-group myResourceGroup --name data-lakehouse
```

3. Update storage class in `manifests/04-persistent-volumes.yaml`:
```yaml
storageClassName: default  # or managed-premium
```

4. Push images to ACR and deploy:
```bash
# Create ACR
az acr create --resource-group myResourceGroup --name mydatalakehouse --sku Basic

# Build and push
az acr build --registry mydatalakehouse --image data-lakehouse/spark:latest docker/spark/
az acr build --registry mydatalakehouse --image data-lakehouse/jupyter:latest docker/notebooks/

# Update kustomization.yaml with ACR URLs
# Deploy
make deploy
```

## Production Considerations

### High Availability

1. **Multiple Spark Masters** (requires Zookeeper):
```yaml
# Add to spark-master deployment
replicas: 3
env:
- name: SPARK_DAEMON_JAVA_OPTS
  value: "-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper.url=zk1:2181,zk2:2181,zk3:2181"
```

2. **MinIO in Distributed Mode**:
```yaml
# Update minio deployment
command: ["minio"]
args: ["server", "http://minio-{0...3}.minio-service.data-lakehouse.svc.cluster.local/data"]
```

### Security

1. **Enable RBAC**:
```bash
kubectl create serviceaccount spark-serviceaccount -n data-lakehouse
kubectl create clusterrolebinding spark-rolebinding --clusterrole=edit --serviceaccount=data-lakehouse:spark-serviceaccount
```

2. **Use Secrets for credentials**:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: minio-credentials
  namespace: data-lakehouse
type: Opaque
data:
  username: bWluaW8=  # base64 encoded
  password: bWluaW8xMjM=  # base64 encoded
```

3. **Enable Pod Security Standards**:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: data-lakehouse
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### Monitoring

1. **Install Prometheus and Grafana**:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

2. **Add ServiceMonitor for Spark**:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: spark-metrics
  namespace: data-lakehouse
spec:
  selector:
    matchLabels:
      app: spark-master
  endpoints:
  - port: metrics
    path: /metrics
```

### Backup and Recovery

1. **Velero for cluster backup**:
```bash
velero install --provider aws --plugins velero/velero-plugin-for-aws:v1.7.0 --bucket velero-backups --secret-file ./credentials-velero
```

2. **Schedule backups**:
```bash
velero schedule create daily-backup --schedule="0 1 * * *" --include-namespaces data-lakehouse
```

## Troubleshooting

### Common Issues

1. **Image Pull Errors**: Ensure images are accessible from your cluster
2. **Storage Issues**: Verify storage class compatibility
3. **Network Policies**: Check if network policies block inter-pod communication
4. **Resource Limits**: Ensure nodes have sufficient resources

### Debug Commands

```bash
# Check cluster info
kubectl cluster-info

# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n data-lakehouse

# Debug network connectivity
kubectl run debug --image=nicolaka/netshoot -it --rm -- /bin/bash
```

For additional support, please check the main README.md or open an issue.