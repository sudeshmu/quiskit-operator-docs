# Features

Qiskit Operator brings enterprise-grade quantum computing to Kubernetes with a comprehensive feature set designed for production workloads.

## Core Features

### 🔧 Kubernetes-Native Design

**Custom Resource Definitions (CRDs)**

Four custom resources for complete quantum workflow management:

- **QiskitJob**: Execute quantum circuits
- **QiskitBackend**: Configure quantum backends
- **QiskitSession**: Manage IBM Quantum Runtime sessions
- **QiskitBudget**: Control costs and quotas

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: my-quantum-job
spec:
  backend:
    type: ibm_quantum
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      qc = QuantumCircuit(2)
      qc.h(0)
      qc.cx(0, 1)
```

**Benefits:**
- Declarative configuration
- GitOps-friendly
- Kubernetes-native tooling
- Standard kubectl commands

---

### 🔐 Multi-Backend Support

Execute quantum circuits on various backends:

| Backend | Type | Status | Cost |
|---------|------|--------|------|
| **IBM Quantum Platform** | Real Hardware + Simulators | ✅ Stable | $$ |
| **Local Simulator** | Qiskit Aer | ✅ Stable | Free |
| **AWS Braket** | Multiple Providers | 🚧 Beta | $$ |
| **Azure Quantum** | Coming Soon | 📋 Planned | $$ |

**Features:**
- Automatic backend selection
- Failover to simulators
- Cost-aware routing
- Backend health monitoring

```yaml
spec:
  backend:
    type: ibm_quantum  # Operator selects best backend
  backendSelection:
    weights:
      cost: 0.70
      queueTime: 0.20
      capability: 0.10
    fallbackToSimulator: true
```

---

### 💰 Intelligent Cost Management

**Budget Control**
- Per-namespace budgets
- Per-job cost limits
- Cost center allocation
- Automatic cost tracking

**Cost Optimization**
- Smart backend selection
- Simulator fallback
- Cost estimation before execution
- Real-time cost monitoring

```yaml
apiVersion: quantum.io/v1
kind: QiskitBudget
metadata:
  name: team-budget
spec:
  limit: "$1000.00"
  period: monthly
  alerts:
    - threshold: 80
      channels: ["slack", "email"]
```

**Cost Visibility:**
```bash
# View job cost
kubectl get qiskitjob my-job -o jsonpath='{.status.cost}'

# Total spending
kubectl get qiskitjobs -o json | \
  jq '[.items[].status.cost | select(. != null) | tonumber] | add'
```

---

### 🛡️ Enterprise Security

**Authentication & Authorization**
- Kubernetes RBAC integration
- Fine-grained permissions
- Secret management for API keys
- Service account isolation

**Pod Security**
- Non-root container execution
- Read-only root filesystem
- Seccomp profiles
- Network policies

**Compliance**
- Audit logging
- Secret encryption at rest
- TLS for all communications
- Pod Security Standards (PSS)

```yaml
# RBAC example
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: quantum-developer
rules:
  - apiGroups: ["quantum.io"]
    resources: ["qiskitjobs"]
    verbs: ["create", "get", "list", "watch"]
```

---

### 📊 Comprehensive Observability

**Metrics (Prometheus)**
- Job success rate and duration
- Backend utilization
- Circuit complexity metrics
- Cost tracking
- Queue time analysis

**Logging (Structured)**
- JSON-formatted logs
- Correlation IDs
- Log levels (DEBUG, INFO, WARN, ERROR)
- Integration with ELK, Splunk, Datadog

**Dashboards (Grafana)**
- Pre-built dashboards
- Job execution timeline
- Cost breakdown
- Backend performance

```bash
# Port-forward to metrics
kubectl port-forward -n qiskit-operator-system \
  svc/qiskit-operator-metrics 8080:8080

# Query metrics
curl http://localhost:8080/metrics
```

---

### 🚀 Circuit Management

**Multiple Source Types**

```yaml
# Inline code
circuit:
  source: inline
  code: |
    from qiskit import QuantumCircuit
    qc = QuantumCircuit(2)

# ConfigMap
circuit:
  source: configmap
  configMapRef:
    name: my-circuit
    key: circuit.py

# Git repository
circuit:
  source: git
  gitRef:
    repository: https://github.com/org/circuits
    branch: main
    path: circuits/bell.py

# HTTP URL
circuit:
  source: url
  url: https://example.com/circuit.py
```

**Circuit Validation**
- Python syntax checking
- Qiskit compatibility validation
- Circuit metrics extraction
- Backend compatibility check
- Cost estimation

---

### ⚡ High Performance

**Optimizations:**
- Circuit transpilation (levels 0-3)
- Parallel job execution
- Efficient resource utilization
- Smart caching

**Performance Metrics:**
| Operation | Time |
|-----------|------|
| Job submission | < 100ms |
| Circuit validation | ~350ms |
| Result retrieval | < 50ms |

**Scalability:**
- Horizontal scaling of operator
- Multiple validation service replicas
- Thousands of concurrent jobs
- Resource quota management

---

### 💾 Flexible Storage

**Multiple Storage Backends:**

```yaml
# ConfigMap (< 1MB)
output:
  type: configmap
  location: results-cm
  format: json

# Persistent Volume
output:
  type: pvc
  location: quantum-results-pvc
  format: pickle

# S3
output:
  type: s3
  location: s3://bucket/results/job-123
  format: json

# GCS
output:
  type: gcs
  location: gs://bucket/results/job-123
  format: qpy
```

**Supported Formats:**
- JSON (human-readable)
- Pickle (Python objects)
- QPY (Qiskit binary format)
- CSV (measurement counts)

---

### 🔄 IBM Quantum Runtime Sessions

**Session Management:**
- Dedicated or shared mode
- Automatic session creation
- Session lifecycle management
- Cost optimization for iterative algorithms

```yaml
apiVersion: quantum.io/v1
kind: QiskitSession
metadata:
  name: vqe-session
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
  maxTime: 3600
  mode: dedicated
```

**Benefits:**
- Reduced queue time
- Lower cost for multiple jobs
- Guaranteed backend access
- Ideal for VQE, QAOA, etc.

---

### 🎯 Smart Backend Selection

**Automatic Backend Selection:**

Operator selects optimal backend based on configurable weights:

```yaml
backendSelection:
  weights:
    cost: 0.50          # Minimize cost
    queueTime: 0.30     # Minimize wait time
    capability: 0.15    # Match circuit requirements
    availability: 0.05  # Prefer available backends
```

**Selection Factors:**
- Current queue depth
- Backend capabilities (qubits, connectivity)
- Cost per shot
- Backend availability
- Historical reliability

---

### 🔧 Developer Experience

**Easy to Use:**
```bash
# Install
helm install qiskit-operator qiskit-operator/qiskit-operator

# Deploy job
kubectl apply -f job.yaml

# Check status
kubectl get qiskitjob my-job

# View results
kubectl get configmap my-results -o yaml
```

**GitOps-Friendly:**
- Declarative YAML configuration
- Version control integration
- ArgoCD/Flux compatible
- Automatic synchronization

**CI/CD Integration:**
```yaml
# GitHub Actions example
- name: Deploy quantum job
  run: |
    kubectl apply -f circuits/job.yaml
    kubectl wait --for=condition=Complete qiskitjob/my-job
```

---

### 🏗️ Production-Ready

**High Availability:**
- Multiple controller replicas
- Leader election
- Automatic failover
- Zero-downtime updates

**Reliability:**
- Automatic retry on failures
- Circuit validation before execution
- Budget checks before submission
- Comprehensive error handling

**Monitoring:**
- Health checks
- Liveness and readiness probes
- Prometheus metrics
- Structured logging

---

### 📦 Multi-Platform Support

**Docker Images:**
- **linux/amd64**: Intel/AMD processors
- **linux/arm64**: Apple Silicon, AWS Graviton

**Platforms:**
- Kubernetes 1.24+
- Kind, Minikube, k3s
- GKE, EKS, AKS
- OpenShift

**Images:**
```bash
docker pull sudeshmu/qiskit-operator:controller-latest
docker pull sudeshmu/qiskit-operator:validation-latest
docker pull sudeshmu/qiskit-operator:executor-latest
```

---

## Feature Comparison

### vs Direct Qiskit Usage

| Feature | Qiskit Operator | Direct Qiskit |
|---------|----------------|---------------|
| **Kubernetes Native** | ✅ CRDs | ❌ Manual scripts |
| **Cost Management** | ✅ Budgets & alerts | ❌ Manual tracking |
| **Multi-Backend** | ✅ Automatic selection | ⚠️ Manual config |
| **Monitoring** | ✅ Prometheus metrics | ❌ Custom logging |
| **RBAC** | ✅ Kubernetes RBAC | ❌ API keys only |
| **GitOps** | ✅ Declarative YAML | ❌ Imperative code |
| **HA & Scaling** | ✅ Built-in | ❌ Manual setup |

### vs Cloud Quantum Services

| Feature | Qiskit Operator | AWS Braket Console | IBM Quantum Dashboard |
|---------|----------------|-------------------|----------------------|
| **Open Source** | ✅ Apache 2.0 | ❌ Proprietary | ❌ Proprietary |
| **Self-Hosted** | ✅ Any Kubernetes | ❌ AWS only | ❌ IBM Cloud only |
| **Multi-Cloud** | ✅ IBM + AWS + Local | ❌ AWS only | ⚠️ IBM only |
| **Cost Control** | ✅ Budgets & limits | ⚠️ AWS Budgets | ⚠️ Basic limits |
| **Automation** | ✅ GitOps + CI/CD | ⚠️ Limited | ⚠️ Limited |
| **Extensible** | ✅ Plugin architecture | ❌ Closed | ❌ Closed |

---

## Roadmap Features

Coming soon:

- [x] IBM Quantum Platform integration
- [x] Local simulator support
- [x] Cost management
- [x] Multi-platform images
- [ ] AWS Braket backend (Beta)
- [ ] Azure Quantum backend
- [ ] Cost optimization ML model
- [ ] Argo Workflows integration
- [ ] Tekton Pipeline integration
- [ ] OperatorHub certification
- [ ] Advanced error mitigation
- [ ] Quantum job scheduling optimizer

---

## Learn More

- [Getting Started](../getting-started/quick-start.md)
- [Architecture](architecture.md)
- [Tutorials](../tutorials/index.md)
- [API Reference](../reference/index.md)

