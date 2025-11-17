# Frequently Asked Questions

Common questions about Qiskit Operator.

## General

### What is Qiskit Operator?

Qiskit Operator is a production-ready Kubernetes operator that enables you to run IBM Qiskit quantum circuits directly from Kubernetes. It provides Kubernetes-native abstractions for quantum computing workloads with enterprise-grade features like cost management, monitoring, and security.

### Why use Qiskit Operator instead of Qiskit directly?

**Benefits:**

- **Kubernetes-Native**: Use standard kubectl and YAML
- **GitOps-Friendly**: Version control your quantum workloads
- **Cost Management**: Built-in budgets and cost tracking
- **Multi-Backend**: Automatic backend selection and failover
- **Enterprise**: RBAC, monitoring, high availability
- **Team Collaboration**: Share resources and results

### Is Qiskit Operator free?

Yes, Qiskit Operator itself is **free and open-source** (Apache 2.0 license). However, you may incur costs for:

- Kubernetes cluster (cloud providers charge)
- IBM Quantum hardware execution (paid)
- AWS Braket execution (paid)
- Object storage for results (S3, GCS)

Local simulators are always free.

### What Kubernetes versions are supported?

Qiskit Operator supports Kubernetes **1.24+**. We test on:

- 1.29 (latest)
- 1.28
- 1.27
- 1.26
- 1.25
- 1.24 (minimum)

## Installation & Setup

### How do I install Qiskit Operator?

**Helm (Recommended):**
```bash
helm repo add qiskit-operator https://quantum-operator.github.io/qiskit-operator
helm install qiskit-operator qiskit-operator/qiskit-operator \
  --namespace qiskit-operator-system \
  --create-namespace
```

See [Installation Guide](../getting-started/installation.md) for other methods.

### Can I run it on my local machine?

Yes! Use:

- **Kind**: Lightweight Kubernetes in Docker
- **Minikube**: Local Kubernetes cluster
- **Docker Desktop**: Built-in Kubernetes

See [Local Development Guide](../getting-started/local-development.md).

### Do I need quantum hardware to use it?

No! You can use the **local simulator** (Qiskit Aer) for free:

```yaml
spec:
  backend:
    type: local_simulator
```

This is perfect for learning, testing, and development.

### How do I get access to IBM Quantum?

1. Sign up at [quantum.ibm.com](https://quantum.ibm.com/) (free tier available)
2. Get your API key from Account Settings
3. Create a Kubernetes secret:

```bash
kubectl create secret generic ibm-quantum-credentials \
  --from-literal=api-key=YOUR_API_KEY
```

See [IBM Quantum Setup](../backends/ibm-quantum.md).

## Usage

### How do I submit a quantum job?

Create a YAML file:

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: my-job
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
    location: my-results
```

Apply it:
```bash
kubectl apply -f job.yaml
```

### How do I get the results?

Results are stored based on your `output` configuration:

```bash
# ConfigMap
kubectl get configmap my-results -o yaml

# Logs
kubectl logs qiskit-job-my-job

# Status
kubectl describe qiskitjob my-job
```

### Can I use circuits from Git?

Yes! Store circuits in Git and reference them:

```yaml
circuit:
  source: git
  gitRef:
    repository: https://github.com/org/circuits
    branch: main
    path: circuits/bell.py
```

### How do I control costs?

Set budgets:

```yaml
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

Enable simulator fallback:

```yaml
spec:
  backendSelection:
    fallbackToSimulator: true
  budget:
    maxCost: "$10.00"
```

## Backends

### Which quantum backends are supported?

| Backend | Status | Cost |
|---------|--------|------|
| Local Simulator (Qiskit Aer) | ✅ Stable | Free |
| IBM Quantum Simulator | ✅ Stable | Free |
| IBM Quantum Hardware | ✅ Stable | $$ |
| AWS Braket | 🚧 Beta | $$ |
| Azure Quantum | 📋 Planned | $$ |

### How does backend selection work?

You can either:

**1. Specify a backend:**
```yaml
backend:
  type: ibm_quantum
  name: ibm_brisbane
```

**2. Let the operator choose:**
```yaml
backend:
  type: ibm_quantum
backendSelection:
  weights:
    cost: 0.70
    queueTime: 0.20
    capability: 0.10
```

### Can I use multiple backends?

Yes! Configure multiple backends and the operator will select based on:

- Availability
- Cost
- Queue time
- Circuit requirements

### What if a backend is unavailable?

Enable automatic fallback:

```yaml
backendSelection:
  fallbackToSimulator: true
  maxQueueTime: 1800  # 30 minutes
```

## Cost & Budget

### How much does quantum computing cost?

**Free:**
- Local simulators (Qiskit Aer)
- IBM Quantum simulators

**Paid:**
- IBM Quantum hardware: ~$1.60/minute of QPU time
- AWS Braket: Varies by provider

### How is cost calculated?

For IBM Quantum:
- Billed per second of QPU time
- Example: 1024 shots on 5-qubit circuit ≈ 10 seconds ≈ $0.27

The operator estimates cost before execution.

### Can I set spending limits?

Yes! Use `QiskitBudget`:

```yaml
spec:
  limit: "$1000.00"
  period: monthly
  alerts:
    - threshold: 75
      channels: ["slack", "email"]
```

Jobs exceeding budget will be rejected.

### How do I track costs?

View job cost:
```bash
kubectl get qiskitjob my-job -o jsonpath='{.status.cost}'
```

Total spending:
```bash
kubectl get qiskitjobs -o json | \
  jq '[.items[].status.cost | select(. != null) | tonumber] | add'
```

## Performance

### How fast is job submission?

- **Job submission**: < 100ms
- **Circuit validation**: ~350ms average
- **Result retrieval**: < 50ms

### Can I run multiple jobs in parallel?

Yes! Each job gets its own executor pod. You can run:

- Hundreds of jobs concurrently
- Limited only by cluster resources
- Kubernetes scheduling applies

### How do I optimize circuit execution?

Use optimization levels:

```yaml
execution:
  optimizationLevel: 3  # 0=none, 1=light, 2=medium, 3=heavy
```

Higher levels take longer to transpile but produce better circuits.

### What about circuit caching?

Circuit validation results are cached. Identical circuits skip re-validation.

## Troubleshooting

### My job is stuck in Pending

Check:

```bash
kubectl describe qiskitjob my-job
kubectl get events --sort-by='.lastTimestamp'
```

Common causes:
- Circuit validation failed
- Budget exceeded
- Backend unavailable
- RBAC permissions

### Circuit validation fails

View validation errors:

```bash
kubectl logs qiskit-validation-service-xxx
kubectl describe qiskitjob my-job
```

Common issues:
- Python syntax error
- Invalid Qiskit code
- Unsupported backend features

### Results not appearing

Check:

```bash
kubectl get pods -l job-name=my-job
kubectl logs qiskit-job-my-job
kubectl describe qiskitjob my-job
```

Verify output configuration is correct.

### Budget exceeded

```bash
kubectl get qiskitbudget -o yaml
kubectl get qiskitjob my-job -o jsonpath='{.status.estimatedCost}'
```

Options:
- Increase budget
- Enable simulator fallback
- Reduce shots
- Use cheaper backend

## Security

### Is it secure?

Yes! Security features:

- **RBAC**: Kubernetes role-based access control
- **Secrets**: Encrypted credential storage
- **Non-root**: All containers run as non-root
- **Network Policies**: Isolate components
- **Pod Security**: Security contexts enforced

### How are API keys stored?

API keys are stored in Kubernetes Secrets:

```bash
kubectl create secret generic ibm-quantum-credentials \
  --from-literal=api-key=YOUR_KEY
```

Secrets are:
- Encrypted at rest (if enabled)
- Only accessible to authorized pods
- Never logged or exposed

### Can I use IAM roles?

For AWS Braket, yes! Use Kubernetes service accounts with IAM roles (IRSA on EKS).

For IBM Quantum, use API keys in secrets.

### Who can submit jobs?

Controlled by Kubernetes RBAC:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: quantum-developer
rules:
  - apiGroups: ["quantum.io"]
    resources: ["qiskitjobs"]
    verbs: ["create", "get", "list"]
```

## Production

### Is it production-ready?

Yes! Used in production by multiple organizations. Features:

- **HA**: High availability deployment
- **Monitoring**: Prometheus metrics
- **Logging**: Structured logging
- **Error Handling**: Automatic retries
- **Scaling**: Horizontal scaling

### How do I deploy for production?

See [Production Deployment Guide](../deployment/production.md).

Key points:
- 3+ controller replicas
- Auto-scaling validation service
- Monitoring enabled
- Resource limits set
- Network policies enabled

### What about high availability?

Controller:
- Leader election
- Multiple replicas
- Automatic failover

Validation service:
- Stateless design
- Multiple replicas
- Load balancing

### How do I monitor it?

Built-in Prometheus metrics:

```bash
kubectl port-forward -n qiskit-operator-system \
  svc/qiskit-operator-metrics 8080:8080
```

Grafana dashboards available.

### Can I backup my quantum jobs?

Yes:

```bash
# Backup all resources
kubectl get qiskitjobs,qiskitbackends,qiskitbudgets \
  -A -o yaml > backup.yaml

# Restore
kubectl apply -f backup.yaml
```

Use Velero for automated backups.

## Development

### How do I contribute?

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

See [Contributing Guide](../development/contributing.md).

### Can I add custom backends?

Yes! Implement the `Backend` interface:

```go
type Backend interface {
    Submit(circuit string, options ExecutionOptions) (JobID, error)
    GetStatus(jobID JobID) (Status, error)
    GetResults(jobID JobID) (Results, error)
}
```

### How do I run tests?

```bash
make test              # Unit tests
make test-integration  # Integration tests
make test-e2e         # E2E tests (requires cluster)
```

### Where can I get help?

- 💬 [GitHub Discussions](https://github.com/quantum-operator/qiskit-operator/discussions)
- 🐛 [GitHub Issues](https://github.com/quantum-operator/qiskit-operator/issues)
- 💼 [Slack Community](https://quantum-operator.slack.com)
- 📧 [Mailing List](https://quantum-operator.io/newsletter)

## Still Have Questions?

- Check the [User Guide](../user-guide/index.md)
- Browse [Tutorials](../tutorials/index.md)
- Join our [Slack Community](https://quantum-operator.slack.com)
- Open a [Discussion](https://github.com/quantum-operator/qiskit-operator/discussions)

---

**Can't find your answer?** [Ask a question](https://github.com/quantum-operator/qiskit-operator/discussions/new) on GitHub!

