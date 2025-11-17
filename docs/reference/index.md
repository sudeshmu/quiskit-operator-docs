# API Reference

Complete reference documentation for all Qiskit Operator Custom Resource Definitions (CRDs).

## Custom Resources

Qiskit Operator extends Kubernetes with four custom resources:

<div class="grid cards" markdown>

-   :material-file-code:{ .lg .middle } **[QiskitJob](qiskitjob.md)**

    ---

    Execute quantum circuits on various backends

    `quantum.io/v1`

    [:octicons-arrow-right-24: View Reference](qiskitjob.md)

-   :material-server:{ .lg .middle } **[QiskitBackend](qiskitbackend.md)**

    ---

    Configure and manage quantum backends

    `quantum.io/v1`

    [:octicons-arrow-right-24: View Reference](qiskitbackend.md)

-   :material-timer:{ .lg .middle } **[QiskitSession](qiskitsession.md)**

    ---

    Manage IBM Quantum Runtime sessions

    `quantum.io/v1`

    [:octicons-arrow-right-24: View Reference](qiskitsession.md)

-   :material-cash:{ .lg .middle } **[QiskitBudget](qiskitbudget.md)**

    ---

    Control costs and enforce quotas

    `quantum.io/v1`

    [:octicons-arrow-right-24: View Reference](qiskitbudget.md)

</div>

## Quick Reference

### QiskitJob

Execute quantum circuits on quantum backends.

**apiVersion**: `quantum.io/v1`  
**kind**: `QiskitJob`

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: example-job
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      qc = QuantumCircuit(2)
      qc.h(0)
      qc.cx(0, 1)
      qc.measure_all()
  execution:
    shots: 1024
  output:
    type: configmap
    location: results
```

**Key Fields:**
- `backend`: Backend configuration
- `circuit`: Circuit code and source
- `execution`: Execution parameters
- `output`: Result storage

[:octicons-arrow-right-24: Full Reference](qiskitjob.md)

---

### QiskitBackend

Configure quantum backend resources.

**apiVersion**: `quantum.io/v1`  
**kind**: `QiskitBackend`

```yaml
apiVersion: quantum.io/v1
kind: QiskitBackend
metadata:
  name: ibm-brisbane
spec:
  type: ibm_quantum
  name: ibm_brisbane
  credentials:
    secretRef:
      name: ibm-credentials
  default: false
```

[:octicons-arrow-right-24: Full Reference](qiskitbackend.md)

---

### QiskitSession

Manage IBM Quantum Runtime sessions.

**apiVersion**: `quantum.io/v1`  
**kind**: `QiskitSession`

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

[:octicons-arrow-right-24: Full Reference](qiskitsession.md)

---

### QiskitBudget

Define cost constraints and quotas.

**apiVersion**: `quantum.io/v1`  
**kind**: `QiskitBudget`

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
      channels: ["slack"]
```

[:octicons-arrow-right-24: Full Reference](qiskitbudget.md)

---

## Common Patterns

### Inline Circuit

```yaml
circuit:
  source: inline
  code: |
    from qiskit import QuantumCircuit
    qc = QuantumCircuit(2, 2)
    qc.h(0)
    qc.cx(0, 1)
    qc.measure([0, 1], [0, 1])
```

### ConfigMap Circuit

```yaml
circuit:
  source: configmap
  configMapRef:
    name: my-circuit
    key: circuit.py
```

### Git Repository Circuit

```yaml
circuit:
  source: git
  gitRef:
    repository: https://github.com/org/circuits
    branch: main
    path: circuits/bell.py
```

### Cost-Optimized Backend Selection

```yaml
backend:
  type: ibm_quantum
backendSelection:
  weights:
    cost: 0.70
    queueTime: 0.20
    capability: 0.10
  fallbackToSimulator: true
```

### Session-Based Execution

```yaml
spec:
  backend:
    type: ibm_quantum
  session:
    name: my-session
    maxTime: 3600
    mode: dedicated
```

## Status Conditions

All resources provide status conditions for monitoring:

```yaml
status:
  phase: Completed
  conditions:
    - type: Validated
      status: "True"
      reason: CircuitValid
      message: Circuit validation successful
    - type: BackendSelected
      status: "True"
      reason: OptimalBackend
      message: Selected ibm_brisbane
```

[:octicons-arrow-right-24: Status Reference](status.md)

## kubectl Commands

### Create Resources

```bash
kubectl apply -f job.yaml
kubectl create -f budget.yaml
```

### List Resources

```bash
kubectl get qiskitjobs
kubectl get qiskitbackends
kubectl get qiskitsessions
kubectl get qiskitbudgets
```

### Describe Resources

```bash
kubectl describe qiskitjob my-job
kubectl describe qiskitbudget team-budget
```

### Delete Resources

```bash
kubectl delete qiskitjob my-job
kubectl delete qiskitbudget team-budget
```

### Watch Resources

```bash
kubectl get qiskitjob my-job -w
kubectl get qiskitjobs -w
```

## Examples

Browse comprehensive examples:

[:octicons-arrow-right-24: View All Examples](examples.md)

**Example Categories:**
- Beginner: Bell State, GHZ State, QRNG
- Intermediate: Grover, QFT, Deutsch-Jozsa
- Advanced: VQE, Shor's Algorithm
- Production: Cost-optimized, Session-based

## Validation

All resources are validated before admission:

- Schema validation (structural)
- Semantic validation (business logic)
- Circuit syntax validation
- Budget enforcement
- RBAC authorization

## API Versioning

Current API version: **v1**

**Version Policy:**
- `v1`: Stable, production-ready
- `v1beta1`: Pre-release, may change
- `v1alpha1`: Experimental, unstable

## Additional Resources

- [User Guide](../user-guide/index.md)
- [Tutorials](../tutorials/index.md)
- [Getting Started](../getting-started/index.md)
- [GitHub Repository](https://github.com/quantum-operator/qiskit-operator)

