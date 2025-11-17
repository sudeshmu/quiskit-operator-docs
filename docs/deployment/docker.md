# Docker Images

Qiskit Operator provides multi-platform Docker images for all components, available on Docker Hub.

## Available Images

### Controller Image

**Image**: `sudeshmu/qiskit-operator:controller-latest`

The main Kubernetes operator controller that manages quantum computing resources.

```bash
docker pull sudeshmu/qiskit-operator:controller-latest
```

**Details:**
- **Size**: ~20 MB
- **Base**: Distroless (gcr.io/distroless/static:nonroot)
- **Platforms**: linux/amd64, linux/arm64
- **Language**: Go
- **Purpose**: CRD reconciliation and job orchestration

**Run Locally:**
```bash
docker run sudeshmu/qiskit-operator:controller-latest
```

### Validation Service Image

**Image**: `sudeshmu/qiskit-operator:validation-latest`

FastAPI-based service for validating and analyzing Qiskit quantum circuits.

```bash
docker pull sudeshmu/qiskit-operator:validation-latest
```

**Details:**
- **Size**: ~1.3 GB (includes Qiskit, NumPy, SciPy)
- **Base**: Python 3.11 Slim
- **Platforms**: linux/amd64, linux/arm64
- **Ports**: 8000
- **Language**: Python
- **Purpose**: Circuit validation and metrics extraction

**Run Locally:**
```bash
docker run -p 8000:8000 sudeshmu/qiskit-operator:validation-latest

# Test the service
curl http://localhost:8000/health
curl -X POST http://localhost:8000/validate \
  -H "Content-Type: application/json" \
  -d '{"code": "from qiskit import QuantumCircuit\nqc = QuantumCircuit(2)"}'
```

### Executor Image

**Image**: `sudeshmu/qiskit-operator:executor-latest`

Executes quantum circuits on various backends.

```bash
docker pull sudeshmu/qiskit-operator:executor-latest
```

**Details:**
- **Size**: ~1.5 GB
- **Base**: Python 3.11 Slim
- **Platforms**: linux/amd64, linux/arm64
- **Language**: Python
- **Purpose**: Circuit execution on quantum backends

## Multi-Platform Support

All images support multiple platforms automatically:

| Platform | Architecture | Examples |
|----------|-------------|----------|
| **linux/amd64** | x86_64 Intel/AMD | Most cloud instances, servers |
| **linux/arm64** | ARM64 | Apple Silicon M1/M2/M3, AWS Graviton, Raspberry Pi 4 |

Docker automatically detects your architecture and pulls the correct variant.

**Verify Platform:**
```bash
docker inspect sudeshmu/qiskit-operator:controller-latest | grep Architecture
```

## Image Tags

### Controller Tags

| Tag | Description | Stability |
|-----|-------------|-----------|
| `controller-latest` | Latest stable release | ✅ Recommended |
| `controller-v1.0.0` | Specific version | ✅ Stable |
| `controller-main` | Development build | ⚠️ Unstable |
| `latest` | Alias for controller-latest | ✅ Stable |

### Validation Service Tags

| Tag | Description | Stability |
|-----|-------------|-----------|
| `validation-latest` | Latest stable release | ✅ Recommended |
| `validation-v1.0.0` | Specific version | ✅ Stable |
| `validation-main` | Development build | ⚠️ Unstable |

### Executor Tags

| Tag | Description | Stability |
|-----|-------------|-----------|
| `executor-latest` | Latest stable release | ✅ Recommended |
| `executor-v1.0.0` | Specific version | ✅ Stable |
| `executor-main` | Development build | ⚠️ Unstable |

## Docker Compose

Run the complete stack locally:

```yaml title="docker-compose.yml"
version: '3.8'

services:
  validation:
    image: sudeshmu/qiskit-operator:validation-latest
    ports:
      - "8000:8000"
    environment:
      - LOG_LEVEL=INFO
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - quantum-net

  controller:
    image: sudeshmu/qiskit-operator:controller-latest
    environment:
      - VALIDATION_SERVICE_URL=http://validation:8000
      - ENABLE_WEBHOOKS=false
    depends_on:
      - validation
    networks:
      - quantum-net

networks:
  quantum-net:
    driver: bridge
```

Start the stack:

```bash
docker-compose up -d
docker-compose logs -f
docker-compose ps
```

## Building Custom Images

### Build Controller

```bash
# Clone repository
git clone https://github.com/quantum-operator/qiskit-operator
cd qiskit-operator

# Build multi-platform image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t your-registry/qiskit-operator:controller-custom \
  --push \
  .
```

### Build Validation Service

```bash
cd validation-service

# Build multi-platform image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t your-registry/qiskit-operator:validation-custom \
  --push \
  .
```

### Build Executor

```bash
cd execution-pods

# Build multi-platform image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t your-registry/qiskit-operator:executor-custom \
  --push \
  .
```

## Image Layers

### Controller Image Layers

```dockerfile
FROM golang:1.21 AS builder
# Build stage: compile Go binary
# Result: ~15 MB binary

FROM gcr.io/distroless/static:nonroot
# Runtime: minimal distroless base
# Final size: ~20 MB
```

### Validation Service Layers

```dockerfile
FROM python:3.11-slim AS builder
# Install Qiskit and dependencies
# Size: ~1.2 GB

FROM python:3.11-slim
# Copy installed packages
# Install runtime dependencies only
# Final size: ~1.3 GB
```

## Security

### Non-Root User

All images run as non-root users:

```bash
# Controller
USER 65532:65532  # nonroot user

# Validation & Executor
USER 1000:1000    # qiskit user
```

### Distroless Base

The controller uses distroless base for minimal attack surface:

- No shell
- No package manager
- Only runtime dependencies
- Regularly updated

### Image Scanning

Images are scanned for vulnerabilities:

```bash
# Scan with Trivy
trivy image sudeshmu/qiskit-operator:controller-latest

# Scan with Snyk
snyk container test sudeshmu/qiskit-operator:controller-latest
```

## Resource Requirements

### Controller

**Recommended:**
```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
```

**Minimum:**
- CPU: 50m
- Memory: 64Mi

### Validation Service

**Recommended:**
```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 2Gi
```

**Minimum:**
- CPU: 250m
- Memory: 512Mi

### Executor (per job)

**Recommended:**
```yaml
resources:
  requests:
    cpu: 1000m
    memory: 2Gi
  limits:
    cpu: 4000m
    memory: 4Gi
```

**Varies by circuit complexity**

## Environment Variables

### Controller

| Variable | Default | Description |
|----------|---------|-------------|
| `ENABLE_WEBHOOKS` | `false` | Enable admission webhooks |
| `METRICS_ADDR` | `:8080` | Metrics endpoint address |
| `HEALTH_PROBE_ADDR` | `:8081` | Health probe address |
| `VALIDATION_SERVICE_URL` | `http://qiskit-validation:8000` | Validation service URL |

### Validation Service

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8000` | Service port |
| `LOG_LEVEL` | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR) |
| `MAX_WORKERS` | `4` | Number of worker threads |

### Executor

| Variable | Default | Description |
|----------|---------|-------------|
| `LOG_LEVEL` | `INFO` | Logging level |
| `BACKEND_TYPE` | - | Backend type (from job spec) |
| `CIRCUIT_CODE` | - | Circuit code (from job spec) |

## Health Checks

### Controller

```bash
# Liveness probe
curl http://localhost:8081/healthz

# Readiness probe
curl http://localhost:8081/readyz
```

### Validation Service

```bash
# Health check
curl http://localhost:8000/health

# Readiness
curl http://localhost:8000/ready
```

## Performance

### Image Pull Times

| Image | Size | Pull Time (1 Gbps) |
|-------|------|---------------------|
| Controller | ~20 MB | ~1 second |
| Validation | ~1.3 GB | ~10 seconds |
| Executor | ~1.5 GB | ~12 seconds |

### Startup Times

| Component | Cold Start | Warm Start |
|-----------|-----------|------------|
| Controller | ~2 seconds | ~1 second |
| Validation | ~5 seconds | ~2 seconds |
| Executor | ~3 seconds | ~1 second |

## Optimization Tips

### Use Image Pull Secrets

```bash
kubectl create secret docker-registry regcred \
  --docker-server=your-registry.com \
  --docker-username=your-username \
  --docker-password=your-password
```

```yaml
spec:
  imagePullSecrets:
    - name: regcred
```

### Configure Image Pull Policy

```yaml
spec:
  containers:
    - name: controller
      image: sudeshmu/qiskit-operator:controller-latest
      imagePullPolicy: IfNotPresent  # or Always, Never
```

### Use Local Registry

```bash
# Set up local registry
docker run -d -p 5000:5000 --name registry registry:2

# Tag and push
docker tag sudeshmu/qiskit-operator:controller-latest localhost:5000/qiskit-operator:controller
docker push localhost:5000/qiskit-operator:controller
```

## Docker Hub

View all images and documentation:

**Repository**: [hub.docker.com/r/sudeshmu/qiskit-operator](https://hub.docker.com/r/sudeshmu/qiskit-operator)

```bash
# Search for images
docker search sudeshmu/qiskit-operator

# View image details
docker inspect sudeshmu/qiskit-operator:controller-latest

# View image history
docker history sudeshmu/qiskit-operator:controller-latest
```

## Troubleshooting

### Image Pull Errors

```bash
# Check image exists
docker pull sudeshmu/qiskit-operator:controller-latest

# Check Docker Hub status
curl https://hub.docker.com/v2/repositories/sudeshmu/qiskit-operator/

# Check credentials
kubectl get secrets -n qiskit-operator-system
```

### Platform Mismatch

```bash
# Force specific platform
docker pull --platform linux/amd64 sudeshmu/qiskit-operator:controller-latest

# Check current platform
docker version | grep "OS/Arch"
```

### Out of Disk Space

```bash
# Clean up unused images
docker image prune -a

# Check disk usage
docker system df

# Remove specific images
docker rmi sudeshmu/qiskit-operator:old-tag
```

## Next Steps

- [Kubernetes Deployment](kubernetes.md)
- [Helm Charts](helm.md)
- [Production Best Practices](production.md)

## Additional Resources

- [Docker Hub Repository](https://hub.docker.com/r/sudeshmu/qiskit-operator)
- [Multi-Platform Build Guide](https://github.com/quantum-operator/qiskit-operator/blob/main/MULTI_PLATFORM_BUILD.md)
- [Dockerfile](https://github.com/quantum-operator/qiskit-operator/blob/main/Dockerfile)

