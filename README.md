# Data Lakehouse with Delta Lake

A production-ready, on-premise Data Lakehouse environment featuring Apache Spark, Delta Lake, and MinIO for S3-compatible object storage.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         JupyterHub (:8000)                       │
│                    Multi-user notebook environment               │
└─────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        ▼                           ▼                           ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│ Spark Master  │◀────────▶│ Spark Worker 1│          │ Spark Worker 2│
│    (:8080)    │          │               │          │               │
└───────────────┘          └───────────────┘          └───────────────┘
        │                           │                           │
        └───────────────────────────┼───────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        ▼                           ▼                           ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│     MinIO     │          │  PostgreSQL   │          │ Delta Lake    │
│ S3 Storage    │          │  Metastore    │          │ Tables        │
│  (:9001)      │          │   (:5432)     │          │               │
└───────────────┘          └───────────────┘          └───────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Git Bash (Windows) or Bash (Linux/macOS)
- 8GB+ RAM recommended

### 1. Clone and Initialize
```bash
git clone https://github.com/your-repo/data-lakehouse-with-delta-lake.git
cd data-lakehouse-with-delta-lake
make init
```

### 2. Configure Environment
Edit `.env` file with your credentials:
```bash
# Copy from template if not exists
cp .env.example .env
# Edit with your preferred values
```

### 3. Build and Start
```bash
make build
make up
```

## 📡 Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| **JupyterHub** | http://localhost:8000 | Sign up / `admin` (admin user) |
| **Standalone Jupyter** | http://localhost:8888 | Token from `.env` |
| **Spark Master UI** | http://localhost:8080 | - |
| **Spark Jobs UI** | http://localhost:4040 | - |
| **MinIO Console** | http://localhost:9001 | From `.env` |

## 📁 Project Structure

```
data-lakehouse-with-delta-lake/
├── docker/                    # Docker configurations
│   ├── spark/                 # Spark cluster image
│   │   ├── Dockerfile
│   │   └── spark-defaults.conf
│   ├── notebook/              # Jupyter notebook image
│   │   ├── Dockerfile
│   │   └── spark-defaults.conf
│   └── jupyterhub/            # JupyterHub image
│       ├── Dockerfile
│       └── jupyterhub_config.py
├── data/                      # Runtime data (git-ignored)
│   ├── notebooks/             # User notebooks (persistent)
│   │   ├── {username}/        # Private user notebooks
│   │   └── shared/            # Shared notebooks for all users
│   └── minio/                 # S3 object storage
├── docs/                      # Documentation
│   ├── PROD_READINESS_PLAN.md
│   ├── TROUBLESHOOTING.md
│   └── PERMISSIONS_FIX.md
├── jars/                      # Downloaded JAR files (git-ignored)
├── scripts/                   # Utility scripts
│   └── download-jars.sh
├── .env                       # Environment variables (git-ignored)
├── .env.example               # Environment template
├── docker-compose.yml         # Main compose file
├── Makefile                   # Build automation
└── README.md
```

## 🛠️ Components & Versions

| Component | Version | Notes |
|-----------|---------|-------|
| Apache Spark | 3.5.0 | Standalone cluster mode |
| Delta Lake | 3.0.0 | Pre-configured JARs & Python package |
| PostgreSQL | 13 | Hive Metastore backend |
| MinIO | Latest | S3-compatible object storage |
| JupyterHub | 3.1.1 | Multi-user notebook server |

## 📦 Pre-installed Python Packages

All notebook environments come with these packages pre-installed:
- `pyspark==3.5.0`
- `delta-spark==3.0.0`
- `pandas`, `pyarrow`, `fastparquet`
- `minio`, `boto3`, `s3fs`
- `psycopg2-binary`, `sqlalchemy`

**No `pip install` required!**

## 💡 Usage Examples

### Create a Delta Table
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("DeltaExample") \
    .getOrCreate()

# Create DataFrame
df = spark.range(100)

# Write as Delta table
df.write.format("delta").save("s3a://warehouse/my_table")

# Read Delta table
df_read = spark.read.format("delta").load("s3a://warehouse/my_table")
df_read.show()
```

### Time Travel Query
```python
# Read specific version
df_v0 = spark.read.format("delta") \
    .option("versionAsOf", 0) \
    .load("s3a://warehouse/my_table")
```

## 🔧 Make Commands

```bash
make help          # Show all available commands
make init          # Initialize project
make build         # Build Docker images
make up            # Start services
make down          # Stop services
make restart       # Restart services
make logs          # View all logs
make logs-spark    # View Spark logs
make rebuild       # Clean rebuild
```

## 📚 Documentation

- [Production Readiness Plan](docs/PROD_READINESS_PLAN.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- [Permissions Fix](docs/PERMISSIONS_FIX.md)

## 🔒 Security Notes

For production deployments:
1. Change all default passwords in `.env`
2. Configure proper authentication (LDAP/OAuth)
3. Enable TLS/HTTPS via reverse proxy
4. Restrict network access to internal services

## 📄 License

See [LICENSE](LICENSE) file.