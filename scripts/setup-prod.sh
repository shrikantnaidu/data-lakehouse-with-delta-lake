#!/bin/bash
#
# Production Setup Script for Data Lakehouse
# ==========================================
# This script creates all necessary directories and configurations
# for a production deployment.
#
# Usage:
#   chmod +x scripts/setup-prod.sh
#   ./scripts/setup-prod.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DATA_DIR="${DATA_DIR:-./data}"
JARS_DIR="${JARS_DIR:-./jars}"
MINIO_DIR="${MINIO_DIR:-./minio}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Data Lakehouse - Production Setup    ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to create directory with proper permissions
create_directory() {
    local dir=$1
    local desc=$2
    
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        chmod 755 "$dir"
        echo -e "${GREEN}✓${NC} Created: $dir ($desc)"
    else
        echo -e "${YELLOW}○${NC} Exists:  $dir ($desc)"
    fi
}

# Function to set permissions for Jupyter (UID 1000, GID 100)
# Uses 775 (rwxrwxr-x) for directories - secure but allows group write
set_jupyter_permissions() {
    local dir=$1
    if [ -d "$dir" ]; then
        # Set ownership to jovyan:users (1000:100)
        chown -R 1000:100 "$dir" 2>/dev/null || true
        # Set directory permissions to 775 (owner/group can write)
        find "$dir" -type d -exec chmod 775 {} \; 2>/dev/null || true
        # Set file permissions to 664 (owner/group can write)
        find "$dir" -type f -exec chmod 664 {} \; 2>/dev/null || true
    fi
}

echo -e "${BLUE}[1/5] Creating data directories...${NC}"
echo "----------------------------------------"

# Main data directory
create_directory "$DATA_DIR" "Main data directory"

# Notebooks directories
create_directory "$DATA_DIR/notebooks" "User notebooks root"
create_directory "$DATA_DIR/notebooks/shared" "Shared notebooks for all users"
create_directory "$DATA_DIR/notebooks/admin" "Admin user notebooks"

# MinIO data directory
create_directory "$DATA_DIR/minio" "MinIO object storage"

# Alternative MinIO mount (some setups use this)
create_directory "$MINIO_DIR" "MinIO data mount"
create_directory "$MINIO_DIR/warehouse" "S3 warehouse bucket"

echo ""
echo -e "${BLUE}[2/5] Creating JAR files directory...${NC}"
echo "----------------------------------------"

create_directory "$JARS_DIR" "Spark/Delta Lake JARs"

echo ""
echo -e "${BLUE}[3/5] Setting permissions...${NC}"
echo "----------------------------------------"

# Set proper permissions for Jupyter user (1000:100)
set_jupyter_permissions "$DATA_DIR/notebooks"
echo -e "${GREEN}✓${NC} Set permissions for notebooks directory"

set_jupyter_permissions "$DATA_DIR/minio"
set_jupyter_permissions "$MINIO_DIR"
echo -e "${GREEN}✓${NC} Set permissions for MinIO directories"

echo ""
echo -e "${BLUE}[4/5] Creating environment file...${NC}"
echo "----------------------------------------"

if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✓${NC} Created .env from template"
        echo -e "${YELLOW}!${NC} ${YELLOW}IMPORTANT: Edit .env with production credentials!${NC}"
    else
        echo -e "${RED}✗${NC} .env.example not found, creating default .env"
        cat > .env << 'EOF'
# MinIO Configuration
MINIO_ROOT_USER=minio
MINIO_ROOT_PASSWORD=CHANGE_ME_MINIO_PASSWORD
MINIO_ACCESS_KEY=minio
MINIO_SECRET_KEY=CHANGE_ME_MINIO_SECRET

# Jupyter Configuration
JUPYTER_TOKEN=CHANGE_ME_JUPYTER_TOKEN
JUPYTER_HUB_PORT=8000
JUPYTER_IMAGE=spark-notebook-base
DOCKER_NETWORK=spark_network

# Spark Configuration
SPARK_MASTER_PORT=7077
SPARK_MASTER_WEBUI_PORT=8080
SPARK_WORKER_MEMORY=4G
SPARK_WORKER_CORES=2

# Metastore Configuration (PostgreSQL)
POSTGRES_USER=hive
POSTGRES_PASSWORD=CHANGE_ME_POSTGRES_PASSWORD
POSTGRES_DB=metastore_db
METASTORE_PORT=5432
EOF
        echo -e "${YELLOW}!${NC} ${YELLOW}IMPORTANT: Edit .env with production credentials!${NC}"
    fi
else
    echo -e "${YELLOW}○${NC} .env already exists"
fi

echo ""
echo -e "${BLUE}[5/5] Downloading JAR files...${NC}"
echo "----------------------------------------"

if [ -x "./scripts/download-jars.sh" ]; then
    echo "Running JAR download script..."
    bash ./scripts/download-jars.sh
else
    echo -e "${YELLOW}!${NC} download-jars.sh not executable, skipping JAR download"
    echo "   Run manually: bash scripts/download-jars.sh"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Directory structure created:"
echo ""
echo "  $DATA_DIR/"
echo "  ├── notebooks/"
echo "  │   ├── shared/        # Shared notebooks"
echo "  │   ├── admin/         # Admin notebooks"
echo "  │   └── {username}/    # User-specific (auto-created)"
echo "  └── minio/             # MinIO data"
echo ""
echo "  $JARS_DIR/             # Spark/Delta JARs"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit .env with production credentials"
echo "  2. Update spark-defaults.conf with MinIO credentials"
echo "  3. Build images: make build"
echo "  4. Start services: make up"
echo ""
echo -e "${RED}Security reminders:${NC}"
echo "  • Change all default passwords"
echo "  • Configure proper authentication (LDAP/OAuth)"
echo "  • Enable TLS/HTTPS via reverse proxy"
echo "  • Restrict network access"
echo ""
