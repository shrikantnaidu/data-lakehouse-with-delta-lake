.PHONY: all build up down restart clean rebuild logs help

# Default target
all: help

# Download JARs first (only once, cached for subsequent builds)
download-jars:
	bash scripts/download-jars.sh

# Fast build with pre-downloaded JARs
build-fast: download-jars
	docker compose build --parallel

# Standard build
build:
	docker compose build

# Start all services
up:
	docker compose up -d

# Stop all services
down:
	docker compose down

# Restart all services
restart: down up

# Clean Docker cache for fresh builds
clean-cache:
	docker builder prune -f

# Full clean and rebuild
rebuild: clean-cache download-jars
	docker compose build --no-cache --parallel

# Setup data directories (basic)
setup-dirs:
	@mkdir -p data/notebooks/shared data/notebooks/admin data/minio minio/warehouse
	@chmod -R 777 data/notebooks 2>/dev/null || true
	@echo "Created data directories"

# Production setup (comprehensive)
setup-prod:
	bash scripts/setup-prod.sh

# View JupyterHub logs
logs-hub:
	docker logs jupyterhub -f

# View Spark Master logs
logs-spark:
	docker logs spark-master -f

# View all logs
logs:
	docker compose logs -f

# Test MinIO connection
test-minio:
	docker exec -it mc mc ls minio/warehouse

# Clean user data (use with caution)
clean-data:
	@echo "WARNING: This will delete all user notebooks and MinIO data!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	rm -rf data/notebooks/* data/minio/*

# Initialize environment
init: setup-dirs download-jars
	@if [ ! -f .env ]; then cp .env.example .env; echo "Created .env from template - please configure it"; fi

# Help
help:
	@echo "Data Lakehouse with Delta Lake - Make Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make init          - Initialize project (create dirs, download JARs, create .env)"
	@echo "  make setup-prod    - Production setup (comprehensive directory + permissions)"
	@echo "  make download-jars - Download required JAR files"
	@echo "  make setup-dirs    - Create data directories"
	@echo ""
	@echo "Build & Run:"
	@echo "  make build         - Build Docker images"
	@echo "  make build-fast    - Build with parallel downloads"
	@echo "  make rebuild       - Clean rebuild (no cache)"
	@echo "  make up            - Start all services"
	@echo "  make down          - Stop all services"
	@echo "  make restart       - Restart all services"
	@echo ""
	@echo "Logs & Debugging:"
	@echo "  make logs          - View all container logs"
	@echo "  make logs-hub      - View JupyterHub logs"
	@echo "  make logs-spark    - View Spark Master logs"
	@echo "  make test-minio    - Test MinIO connection"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean-cache   - Clean Docker build cache"
	@echo "  make clean-data    - Remove all user data (DANGEROUS)"

