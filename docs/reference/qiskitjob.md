# QiskitJob API Reference

The `QiskitJob` custom resource represents a quantum circuit execution job on Kubernetes.

## Resource Definition

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: string
  namespace: string
  labels:
    key: value
  annotations:
    key: value
spec:
  # Required fields
  backend: BackendSpec
  circuit: CircuitSpec
  
  # Optional fields
  execution: ExecutionSpec
  session: SessionSpec
  resources: ResourceRequirements
  budget: BudgetSpec
  output: OutputSpec
  credentials: CredentialsSpec
  backendSelection: BackendSelectionSpec

status:
  phase: string
  conditions: []Condition
  startTime: timestamp
  completionTime: timestamp
  backend: string
  cost: string
  results: ResultsSpec
```

## Spec Fields

### backend (required)

Defines the quantum backend configuration.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | Backend type: `ibm_quantum`, `ibm_simulator`, `aws_braket`, `local_simulator` |
| `name` | string | No | Specific backend name (e.g., `ibm_brisbane`) |
| `instance` | string | No | IBM Cloud CRN for enterprise accounts |
| `hub` | string | No | IBM Quantum Network hub (legacy) |
| `group` | string | No | IBM Quantum Network group (legacy) |
| `project` | string | No | IBM Quantum Network project (legacy) |

**Example:**

```yaml
backend:
  type: ibm_quantum
  name: ibm_brisbane
  instance: crn:v1:bluemix:public:quantum-computing:...
```

### circuit (required)

Defines the quantum circuit to execute.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `source` | string | Yes | Circuit source: `inline`, `configmap`, `url`, `git` |
| `code` | string | Conditional | Inline Qiskit Python code (required if source=inline) |
| `configMapRef` | object | Conditional | ConfigMap reference (required if source=configmap) |
| `url` | string | Conditional | Circuit URL (required if source=url) |
| `gitRef` | object | Conditional | Git repository reference (required if source=git) |

**Inline Example:**

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

**ConfigMap Example:**

```yaml
circuit:
  source: configmap
  configMapRef:
    name: my-circuit
    key: circuit.py
```

**Git Example:**

```yaml
circuit:
  source: git
  gitRef:
    repository: https://github.com/org/quantum-algorithms
    branch: main
    path: circuits/bell_state.py
```

### execution (optional)

Execution parameters for the quantum circuit.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `shots` | integer | 1024 | Number of circuit executions |
| `optimizationLevel` | integer | 1 | Transpiler optimization level (0-3) |
| `priority` | string | normal | Job priority: `low`, `normal`, `high`, `urgent` |
| `timeout` | string | 1h | Maximum execution time |
| `maxRetries` | integer | 3 | Maximum retry attempts |

**Example:**

```yaml
execution:
  shots: 8192
  optimizationLevel: 3
  priority: high
  timeout: 2h
  maxRetries: 5
```

### session (optional)

IBM Quantum Runtime session configuration.

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Session name or reference |
| `maxTime` | integer | Maximum session duration (seconds) |
| `mode` | string | Session mode: `dedicated` or `shared` |

**Example:**

```yaml
session:
  name: vqe-session
  maxTime: 3600
  mode: dedicated
```

### resources (optional)

Pod resource requirements for job execution.

| Field | Type | Description |
|-------|------|-------------|
| `requests.cpu` | string | CPU request |
| `requests.memory` | string | Memory request |
| `limits.cpu` | string | CPU limit |
| `limits.memory` | string | Memory limit |

**Example:**

```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 4Gi
```

### budget (optional)

Budget constraints and cost management.

| Field | Type | Description |
|-------|------|-------------|
| `maxCost` | string | Maximum allowed cost (e.g., "$10.00") |
| `costCenter` | string | Cost center for accounting |
| `project` | string | Project name for billing |

**Example:**

```yaml
budget:
  maxCost: "$50.00"
  costCenter: quantum-research
  project: drug-discovery
```

### output (optional)

Result storage configuration.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `type` | string | configmap | Storage type: `configmap`, `pvc`, `s3`, `gcs` |
| `location` | string | - | Storage location (name/path) |
| `format` | string | json | Result format: `json`, `pickle`, `qpy`, `csv` |

**ConfigMap Example:**

```yaml
output:
  type: configmap
  location: my-results
  format: json
```

**S3 Example:**

```yaml
output:
  type: s3
  location: s3://my-bucket/results/job-123
  format: pickle
```

### credentials (optional)

Backend authentication credentials.

| Field | Type | Description |
|-------|------|-------------|
| `secretRef.name` | string | Secret name containing credentials |

**Example:**

```yaml
credentials:
  secretRef:
    name: ibm-quantum-credentials
```

Secret should contain:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ibm-quantum-credentials
type: Opaque
stringData:
  api-key: YOUR_IBM_QUANTUM_API_KEY
```

### backendSelection (optional)

Smart backend selection preferences.

| Field | Type | Description |
|-------|------|-------------|
| `weights.cost` | float | Weight for cost (0.0-1.0) |
| `weights.queueTime` | float | Weight for queue time (0.0-1.0) |
| `weights.capability` | float | Weight for backend capability (0.0-1.0) |
| `weights.availability` | float | Weight for availability (0.0-1.0) |
| `fallbackToSimulator` | boolean | Fallback to simulator if cost exceeds budget |

**Example:**

```yaml
backendSelection:
  weights:
    cost: 0.70
    queueTime: 0.15
    capability: 0.10
    availability: 0.05
  fallbackToSimulator: true
```

## Status Fields

### phase

Current job phase:

| Phase | Description |
|-------|-------------|
| `Pending` | Job created, awaiting validation |
| `Validating` | Circuit validation in progress |
| `Scheduling` | Backend selection and pod scheduling |
| `Running` | Circuit execution in progress |
| `Completed` | Job completed successfully |
| `Failed` | Job failed |
| `Cancelled` | Job was cancelled |

### conditions

Array of condition objects describing job status.

```yaml
conditions:
  - type: Validated
    status: "True"
    reason: CircuitValid
    message: Circuit validation successful
  - type: BackendSelected
    status: "True"
    reason: OptimalBackend
    message: Selected ibm_brisbane based on cost
```

### results

Job execution results.

```yaml
results:
  counts:
    "00": 512
    "11": 512
  executionTime: 1.234
  queueTime: 45.67
  totalTime: 46.904
```

## Complete Examples

### Basic Local Simulator Job

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: bell-state
  namespace: default
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
    location: bell-state-results
```

### IBM Quantum Hardware Job

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: hardware-job
  namespace: production
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
  
  circuit:
    source: configmap
    configMapRef:
      name: grover-circuit
      key: circuit.py
  
  execution:
    shots: 8192
    optimizationLevel: 3
    priority: high
  
  budget:
    maxCost: "$100.00"
    costCenter: quantum-research
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  output:
    type: s3
    location: s3://quantum-results/production/hardware-job
    format: json
```

### Cost-Optimized Job with Session

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: vqe-optimization
  namespace: research
spec:
  backend:
    type: ibm_quantum
  
  backendSelection:
    weights:
      cost: 0.80
      queueTime: 0.10
      capability: 0.05
      availability: 0.05
    fallbackToSimulator: true
  
  circuit:
    source: git
    gitRef:
      repository: https://github.com/org/quantum-algorithms
      branch: main
      path: vqe/h2_molecule.py
  
  execution:
    shots: 4096
    optimizationLevel: 3
  
  session:
    name: vqe-session
    maxTime: 3600
    mode: dedicated
  
  budget:
    maxCost: "$50.00"
    costCenter: chemistry-research
    project: drug-discovery
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  resources:
    requests:
      cpu: 1000m
      memory: 2Gi
    limits:
      cpu: 4000m
      memory: 8Gi
  
  output:
    type: pvc
    location: quantum-results-pvc
    format: pickle
```

## kubectl Commands

### Create Job

```bash
kubectl apply -f job.yaml
```

### List Jobs

```bash
kubectl get qiskitjobs
kubectl get qiskitjobs -A  # All namespaces
kubectl get qiskitjobs -w  # Watch mode
```

### Describe Job

```bash
kubectl describe qiskitjob <name>
```

### Get Job Status

```bash
kubectl get qiskitjob <name> -o jsonpath='{.status.phase}'
```

### Get Job Results

```bash
# ConfigMap output
kubectl get configmap <results-name> -o yaml

# View counts
kubectl get configmap <results-name> -o jsonpath='{.data.counts}'
```

### Delete Job

```bash
kubectl delete qiskitjob <name>
```

### Watch Job Logs

```bash
kubectl logs qiskit-job-<name> -f
```

## Status and Monitoring

### Check Job Progress

```bash
kubectl get qiskitjob my-job -o jsonpath='{.status.phase}'
```

### View Conditions

```bash
kubectl get qiskitjob my-job -o jsonpath='{.status.conditions[*].type}'
```

### Get Cost Information

```bash
kubectl get qiskitjob my-job -o jsonpath='{.status.cost}'
```

### View Metrics

```bash
# Prometheus metrics
kubectl port-forward -n qiskit-operator-system svc/qiskit-operator-metrics 8080:8080

# Query metrics
curl http://localhost:8080/metrics | grep qiskit_job
```

## Best Practices

### 1. Use Descriptive Names

```yaml
metadata:
  name: grover-3qubit-search-20250117
  labels:
    app: quantum-search
    algorithm: grover
    team: research
```

### 2. Set Resource Limits

```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 4Gi
```

### 3. Configure Budgets

```yaml
budget:
  maxCost: "$10.00"
  costCenter: team-alpha
```

### 4. Use Secrets for Credentials

```bash
kubectl create secret generic my-creds \
  --from-literal=api-key=XXX
```

### 5. Enable Monitoring

```yaml
metadata:
  labels:
    monitoring: enabled
```

## Troubleshooting

### Job Stuck in Pending

```bash
kubectl describe qiskitjob <name>
kubectl get events --sort-by='.lastTimestamp'
```

### Validation Failures

```bash
kubectl logs qiskit-job-<name>
kubectl get qiskitjob <name> -o jsonpath='{.status.conditions}'
```

### Cost Exceeded

```yaml
status:
  phase: Failed
  conditions:
    - type: BudgetExceeded
      status: "True"
      message: Estimated cost $15.00 exceeds budget $10.00
```

## Related Resources

- [QiskitBackend](qiskitbackend.md)
- [QiskitSession](qiskitsession.md)
- [QiskitBudget](qiskitbudget.md)
- [Examples](examples.md)

