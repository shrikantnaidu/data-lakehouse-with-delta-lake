.PHONY: build deploy clean scale logs help

# Default target
help:
	@echo "Data Lakehouse on Kubernetes - Available targets:"
	@echo ""
	@echo "  build     - Build Docker images"
	@echo "  deploy    - Deploy to Kubernetes cluster"
	@echo "  clean     - Remove all resources from cluster"
	@echo "  scale     - Scale Spark workers (use WORKERS=N)"
	@echo "  logs      - Show logs from all services"
	@echo "  status    - Show status of all pods and services"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make deploy"
	@echo "  make scale WORKERS=3"
	@echo "  make logs"
	@echo "  make clean"

build:
	@echo "Building Docker images..."
	./scripts/build-images.sh

deploy:
	@echo "Deploying to Kubernetes..."
	./scripts/deploy.sh

clean:
	@echo "Cleaning up deployment..."
	./scripts/cleanup.sh

scale:
	@echo "Scaling Spark workers..."
	./scripts/scale.sh --workers $(or $(WORKERS),2)

logs:
	@echo "=== Spark Master Logs ==="
	kubectl logs -n data-lakehouse deployment/spark-master --tail=50 || true
	@echo ""
	@echo "=== Jupyter Notebook Logs ==="
	kubectl logs -n data-lakehouse deployment/jupyter-notebook --tail=50 || true
	@echo ""
	@echo "=== MinIO Logs ==="
	kubectl logs -n data-lakehouse deployment/minio --tail=50 || true
	@echo ""
	@echo "=== Spark Worker Logs ==="
	kubectl logs -n data-lakehouse deployment/spark-worker --tail=50 || true

status:
	@echo "=== Namespace Status ==="
	kubectl get namespace data-lakehouse || true
	@echo ""
	@echo "=== Pod Status ==="
	kubectl get pods -n data-lakehouse || true
	@echo ""
	@echo "=== Service Status ==="
	kubectl get services -n data-lakehouse || true
	@echo ""
	@echo "=== Persistent Volume Status ==="
	kubectl get pv | grep data-lakehouse || true
	@echo ""
	@echo "=== Persistent Volume Claim Status ==="
	kubectl get pvc -n data-lakehouse || true