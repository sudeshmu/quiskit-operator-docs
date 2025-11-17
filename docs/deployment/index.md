# Deployment Guide

Learn how to deploy Qiskit Operator in various environments, from development to production.

## Deployment Options

Choose the deployment method that best fits your needs:

<div class="grid cards" markdown>

-   :material-docker:{ .lg .middle } **[Docker Images](docker.md)**

    ---

    Multi-platform container images on Docker Hub

    [:octicons-arrow-right-24: Learn More](docker.md)

-   :material-kubernetes:{ .lg .middle } **[Kubernetes](kubernetes.md)**

    ---

    Deploy to any Kubernetes cluster

    [:octicons-arrow-right-24: Learn More](kubernetes.md)

-   :material-ship-wheel:{ .lg .middle } **[Helm Charts](helm.md)**

    ---

    Install using Helm package manager

    [:octicons-arrow-right-24: Learn More](helm.md)

-   :material-shield-check:{ .lg .middle } **[Production](production.md)**

    ---

    Production-ready deployment with HA

    [:octicons-arrow-right-24: Learn More](production.md)

</div>

## Quick Start

### Install with Helm

```bash
helm repo add qiskit-operator https://quantum-operator.github.io/qiskit-operator
helm install qiskit-operator qiskit-operator/qiskit-operator \
  --namespace qiskit-operator-system \
  --create-namespace
```

### Verify Installation

```bash
kubectl get pods -n qiskit-operator-system
kubectl get crds | grep quantum.io
```

## Deployment Architectures

### Development

Minimal setup for local development:

```yaml
controller:
  replicas: 1
validation:
  replicas: 1
resources:
  requests:
    cpu: 100m
    memory: 128Mi
```

**Use Cases:** Testing, development, learning

---

### Staging

Production-like environment with moderate resources:

```yaml
controller:
  replicas: 2
validation:
  replicas: 2
resources:
  requests:
    cpu: 500m
    memory: 512Mi
monitoring:
  enabled: true
```

**Use Cases:** Pre-production testing, QA

---

### Production

High-availability setup with monitoring:

```yaml
controller:
  replicas: 3
  affinity:
    podAntiAffinity: preferred
validation:
  replicas: 5
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
resources:
  limits:
    cpu: 2000m
    memory: 2Gi
monitoring:
  enabled: true
  prometheus: true
  grafana: true
networkPolicy:
  enabled: true
podSecurityPolicy:
  enabled: true
```

**Use Cases:** Production workloads, enterprise

---

## Infrastructure Requirements

### Minimum Requirements

| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Controller | 100m | 128Mi | - |
| Validation | 500m | 1Gi | - |
| Executor (per job) | 500m | 1Gi | - |
| **Total** | **1.1 cores** | **2.1 GB** | **10 GB** |

### Recommended (Production)

| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Controller (×3) | 500m | 256Mi | - |
| Validation (×5) | 1000m | 2Gi | - |
| etcd | 1000m | 2Gi | 20Gi |
| Prometheus | 2000m | 4Gi | 50Gi |
| **Total** | **9.5 cores** | **18 GB** | **70 GB** |

### Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| **GKE** | ✅ Fully Supported | Google Kubernetes Engine |
| **EKS** | ✅ Fully Supported | Amazon Elastic Kubernetes Service |
| **AKS** | ✅ Fully Supported | Azure Kubernetes Service |
| **OpenShift** | ✅ Fully Supported | Red Hat OpenShift |
| **Kind** | ✅ Fully Supported | Local development |
| **Minikube** | ✅ Fully Supported | Local development |
| **k3s** | ✅ Fully Supported | Lightweight Kubernetes |
| **Docker Desktop** | ✅ Fully Supported | Local development |

---

## Deployment Checklist

### Pre-Deployment

- [ ] Kubernetes cluster (1.24+) available
- [ ] kubectl configured and working
- [ ] Sufficient resources allocated
- [ ] Network policies reviewed
- [ ] Storage classes configured
- [ ] Monitoring stack ready (optional)

### Deployment

- [ ] Install CRDs
- [ ] Deploy operator controller
- [ ] Deploy validation service
- [ ] Configure RBAC
- [ ] Create secrets for backends
- [ ] Verify all pods running

### Post-Deployment

- [ ] Submit test job
- [ ] Verify results
- [ ] Check metrics
- [ ] Configure monitoring alerts
- [ ] Set up backup strategy
- [ ] Document deployment

---

## Configuration

### Basic Configuration

```yaml title="values.yaml"
controller:
  image:
    repository: sudeshmu/qiskit-operator
    tag: controller-latest
  replicas: 2

validation:
  image:
    repository: sudeshmu/qiskit-operator
    tag: validation-latest
  replicas: 3

rbac:
  create: true

networkPolicy:
  enabled: false
```

### Advanced Configuration

```yaml title="values-production.yaml"
controller:
  replicas: 3
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: app
                  operator: In
                  values:
                    - qiskit-operator
            topologyKey: kubernetes.io/hostname

validation:
  replicas: 5
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPU: 70
    targetMemory: 80
  resources:
    requests:
      cpu: 1000m
      memory: 2Gi
    limits:
      cpu: 4000m
      memory: 4Gi

monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s

networkPolicy:
  enabled: true
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: monitoring

podSecurityPolicy:
  enabled: true

securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

persistence:
  enabled: true
  storageClass: fast-ssd
  size: 10Gi
```

---

## Upgrade Strategy

### Rolling Update (Default)

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1
```

### Blue-Green Deployment

```bash
# Deploy new version
helm install qiskit-operator-v2 qiskit-operator/qiskit-operator \
  --namespace qiskit-operator-v2 \
  --create-namespace

# Test new version
kubectl apply -f test-job.yaml --namespace qiskit-operator-v2

# Switch traffic
kubectl label namespace qiskit-operator-v2 active=true
kubectl label namespace qiskit-operator-system active=false

# Remove old version
helm uninstall qiskit-operator --namespace qiskit-operator-system
```

---

## High Availability

### Controller HA

- 3+ replicas
- Leader election
- Automatic failover
- Pod anti-affinity

### Validation Service HA

- 5+ replicas
- Load balancing
- Auto-scaling
- Health checks

### Data HA

- etcd cluster (3+ nodes)
- Regular backups
- Point-in-time recovery

---

## Monitoring & Observability

### Metrics

```yaml
monitoring:
  prometheus:
    enabled: true
    serviceMonitor:
      enabled: true
  grafana:
    enabled: true
    dashboards:
      enabled: true
```

### Logging

```yaml
logging:
  level: info
  format: json
  output: stdout
```

### Tracing

```yaml
tracing:
  enabled: true
  backend: jaeger
  endpoint: http://jaeger-collector:14268/api/traces
```

---

## Security

### Pod Security

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
```

### Network Security

```yaml
networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: qiskit-operator
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: qiskit-validation
```

### Secret Management

```bash
# Create secrets
kubectl create secret generic ibm-quantum-credentials \
  --from-literal=api-key=xxx \
  --namespace default

# Use external secret management
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ibm-quantum-credentials
spec:
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: ibm-quantum-credentials
  data:
    - secretKey: api-key
      remoteRef:
        key: quantum/ibm
        property: api-key
EOF
```

---

## Backup & Disaster Recovery

### Backup Strategy

```bash
# Backup CRDs
kubectl get crds -o yaml > crds-backup.yaml

# Backup resources
kubectl get qiskitjobs,qiskitbackends,qiskitsessions,qiskitbudgets \
  -A -o yaml > resources-backup.yaml

# Backup with Velero
velero backup create qiskit-operator-backup \
  --include-namespaces qiskit-operator-system
```

### Restore

```bash
# Restore CRDs
kubectl apply -f crds-backup.yaml

# Restore resources
kubectl apply -f resources-backup.yaml

# Restore with Velero
velero restore create --from-backup qiskit-operator-backup
```

---

## Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl describe pod -n qiskit-operator-system
kubectl logs -n qiskit-operator-system deployment/qiskit-operator-controller
```

**CRDs not installing:**
```bash
kubectl get crds | grep quantum.io
kubectl describe crd qiskitjobs.quantum.io
```

**RBAC permissions:**
```bash
kubectl auth can-i create qiskitjobs --as=system:serviceaccount:default:default
```

---

## Next Steps

- [Production Best Practices](production.md)
- [High Availability Setup](ha.md)
- [Scaling Guide](scaling.md)
- [Security Hardening](security.md)

## Additional Resources

- [Helm Chart Repository](https://github.com/quantum-operator/qiskit-operator-helm)
- [Docker Images](https://hub.docker.com/r/sudeshmu/qiskit-operator)
- [GitHub Repository](https://github.com/quantum-operator/qiskit-operator)

