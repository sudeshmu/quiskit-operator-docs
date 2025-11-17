# User Guide

Comprehensive guide to using Qiskit Operator for quantum computing on Kubernetes.

## Overview

This user guide covers all aspects of using Qiskit Operator, from basic job submission to advanced production deployments.

## Quick Navigation

<div class="grid cards" markdown>

-   :material-rocket:{ .lg .middle } **[Quantum Jobs](quantum-jobs.md)**

    ---

    Create and manage quantum circuit executions

    [:octicons-arrow-right-24: Learn More](quantum-jobs.md)

-   :material-server:{ .lg .middle } **[Backends](backends.md)**

    ---

    Configure quantum backends (IBM, AWS, local)

    [:octicons-arrow-right-24: Learn More](backends.md)

-   :material-timer:{ .lg .middle } **[Sessions](sessions.md)**

    ---

    Manage IBM Quantum Runtime sessions

    [:octicons-arrow-right-24: Learn More](sessions.md)

-   :material-cash:{ .lg .middle } **[Budget Management](budget.md)**

    ---

    Control costs and enforce spending limits

    [:octicons-arrow-right-24: Learn More](budget.md)

-   :material-code-braces:{ .lg .middle } **[Circuits](circuits.md)**

    ---

    Manage quantum circuit code and sources

    [:octicons-arrow-right-24: Learn More](circuits.md)

-   :material-database:{ .lg .middle } **[Storage](storage.md)**

    ---

    Configure result storage options

    [:octicons-arrow-right-24: Learn More](storage.md)

-   :material-shield:{ .lg .middle } **[Security & RBAC](security.md)**

    ---

    Implement security and access control

    [:octicons-arrow-right-24: Learn More](security.md)

-   :material-chart-line:{ .lg .middle } **[Monitoring](monitoring.md)**

    ---

    Monitor jobs and system health

    [:octicons-arrow-right-24: Learn More](monitoring.md)

</div>

## Getting Started

### Prerequisites

Before using Qiskit Operator, ensure:

- Qiskit Operator is installed on your Kubernetes cluster
- You have appropriate RBAC permissions
- kubectl is configured

### Basic Workflow

```mermaid
graph LR
    A[Create YAML] --> B[Apply to Cluster]
    B --> C[Job Validates]
    C --> D[Backend Selected]
    D --> E[Circuit Executes]
    E --> F[Results Stored]
    
    style A fill:#6d4c7d
    style B fill:#6d4c7d
    style C fill:#6d4c7d
    style D fill:#6d4c7d
    style E fill:#6d4c7d
    style F fill:#6d4c7d
```

### Your First Job

```yaml title="hello-quantum.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: hello-quantum
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      qc = QuantumCircuit(2, 2)
      qc.h(0)
      qc.cx(0, 1)
      qc.measure([0, 1], [0, 1])
  execution:
    shots: 1024
  output:
    type: configmap
    location: hello-quantum-results
```

Apply and monitor:

```bash
kubectl apply -f hello-quantum.yaml
kubectl get qiskitjob hello-quantum -w
kubectl get configmap hello-quantum-results -o yaml
```

## Core Concepts

### Quantum Jobs

A **QiskitJob** represents a quantum circuit execution request. It includes:

- **Backend**: Where to execute (IBM Quantum, AWS, local)
- **Circuit**: The quantum algorithm to run
- **Execution**: Parameters like shots and optimization
- **Output**: Where to store results

### Backends

A **Backend** is a quantum processor or simulator where circuits execute:

- **IBM Quantum**: Real hardware and cloud simulators
- **AWS Braket**: Multiple quantum providers
- **Local Simulator**: Qiskit Aer on Kubernetes

### Sessions

**Sessions** group related jobs for iterative algorithms:

- Reduced queue time
- Lower cost
- Dedicated or shared QPU access

### Budgets

**Budgets** control spending:

- Per-namespace limits
- Per-job maximums
- Automatic cost tracking
- Alert thresholds

## Common Patterns

### Pattern 1: Test on Simulator, Deploy to Hardware

```bash
# Test locally
kubectl apply -f job-simulator.yaml
kubectl wait --for=condition=Complete qiskitjob/my-job

# Deploy to hardware
kubectl apply -f job-hardware.yaml
```

### Pattern 2: Cost-Optimized Execution

```yaml
spec:
  backend:
    type: ibm_quantum
  backendSelection:
    weights:
      cost: 0.80
      queueTime: 0.20
    fallbackToSimulator: true
  budget:
    maxCost: "$10.00"
```

### Pattern 3: Session-Based VQE

```yaml
# Create session
apiVersion: quantum.io/v1
kind: QiskitSession
metadata:
  name: vqe-session
spec:
  backend:
    type: ibm_quantum
  maxTime: 3600
---
# Use session
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: vqe-iteration-1
spec:
  session:
    name: vqe-session
  circuit:
    source: inline
    code: |
      # VQE circuit code
```

### Pattern 4: GitOps Workflow

```yaml
# Store circuits in Git
circuit:
  source: git
  gitRef:
    repository: https://github.com/org/circuits
    branch: main
    path: production/circuit.py
```

## Best Practices

### 1. Resource Organization

```bash
# Use namespaces
kubectl create namespace quantum-prod
kubectl create namespace quantum-dev

# Label resources
metadata:
  labels:
    team: research
    project: drug-discovery
    environment: production
```

### 2. Cost Management

```yaml
# Set budgets
apiVersion: quantum.io/v1
kind: QiskitBudget
metadata:
  name: team-budget
spec:
  limit: "$500.00"
  period: monthly
  alerts:
    - threshold: 80
      channels: ["slack"]
```

### 3. Circuit Validation

All circuits are validated before execution:

- Python syntax check
- Qiskit compatibility
- Backend requirements
- Cost estimation

### 4. Monitoring

```bash
# Watch job status
kubectl get qiskitjobs -w

# View logs
kubectl logs qiskit-job-my-job

# Check metrics
kubectl port-forward -n qiskit-operator-system \
  svc/qiskit-operator-metrics 8080:8080
```

## Advanced Topics

### Multi-Backend Deployments

Configure multiple backends for high availability:

```yaml
apiVersion: quantum.io/v1
kind: QiskitBackend
metadata:
  name: ibm-primary
spec:
  type: ibm_quantum
  name: ibm_brisbane
  priority: 100
---
apiVersion: quantum.io/v1
kind: QiskitBackend
metadata:
  name: ibm-fallback
spec:
  type: ibm_quantum
  name: ibm_kyoto
  priority: 90
```

### Custom Storage Backends

Store results in various locations:

```yaml
# ConfigMap (< 1MB)
output:
  type: configmap
  
# Persistent Volume
output:
  type: pvc
  location: quantum-results

# Object Storage
output:
  type: s3
  location: s3://bucket/results
```

### RBAC Configuration

Fine-grained access control:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: quantum-developer
rules:
  - apiGroups: ["quantum.io"]
    resources: ["qiskitjobs"]
    verbs: ["create", "get", "list", "watch"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list"]
```

## Troubleshooting

### Common Issues

**Job stuck in Pending:**
```bash
kubectl describe qiskitjob my-job
kubectl get events --sort-by='.lastTimestamp'
```

**Circuit validation failed:**
```bash
kubectl logs qiskit-validation-service-xxx
```

**Budget exceeded:**
```bash
kubectl get qiskitbudget -o yaml
kubectl get qiskitjob my-job -o jsonpath='{.status.cost}'
```

**Results not appearing:**
```bash
kubectl get configmaps
kubectl describe qiskitjob my-job
```

## Next Steps

<div class="grid cards" markdown>

-   :material-school:{ .lg .middle } **Tutorials**

    ---

    Step-by-step learning guides

    [:octicons-arrow-right-24: View Tutorials](../tutorials/index.md)

-   :material-file-document:{ .lg .middle } **API Reference**

    ---

    Complete CRD specifications

    [:octicons-arrow-right-24: View Reference](../reference/index.md)

-   :material-server-network:{ .lg .middle } **Deployment**

    ---

    Production deployment guides

    [:octicons-arrow-right-24: View Deployment](../deployment/index.md)

-   :material-forum:{ .lg .middle } **Community**

    ---

    Get help and support

    [:octicons-arrow-right-24: Join Community](../community/index.md)

</div>

## Additional Resources

- [Getting Started Guide](../getting-started/index.md)
- [Architecture Overview](../home/architecture.md)
- [Example Circuits](../reference/examples.md)
- [GitHub Repository](https://github.com/quantum-operator/qiskit-operator)

