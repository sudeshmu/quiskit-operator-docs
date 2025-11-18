# QiskitJob API Reference

Complete API reference for the `QiskitJob` Custom Resource Definition.

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
  # Full specification documented below
status:
  # Status fields documented below
```

## Spec Fields

### Backend (`BackendSpec`)

**Required**. Specifies the quantum backend for circuit execution.

```yaml
backend:
  type: string              # Required: Backend type
  name: string              # Optional: Specific backend name
  instance: string          # Optional: IBM Cloud instance CRN
  hub: string               # Optional: IBM Quantum hub (legacy)
  group: string             # Optional: IBM Quantum group (legacy)
  project: string           # Optional: IBM Quantum project (legacy)
```

#### `type` Field

**Required**. Backend type for execution.

| Value | Description | Cost | Noise |
|-------|-------------|------|-------|
| `local_simulator` | Local Qiskit Aer simulator | Free | None |
| `ibm_simulator` | IBM Cloud simulator | Low | Configurable |
| `ibm_quantum` | Real IBM quantum computer | High | Real quantum noise |
| `aws_braket` | AWS Braket service | Medium-High | Varies |

**Example:**

```yaml
backend:
  type: local_simulator
```

#### `name` Field

**Optional**. Specific backend name. If omitted, automatic selection is performed.

**IBM Quantum Backends:**
- `ibm_brisbane` (127 qubits)
- `ibm_kyoto` (127 qubits)
- `ibm_osaka` (127 qubits)
- Check [IBM Quantum](https://quantum.ibm.com/) for current availability

**AWS Braket Backends:**
- `arn:aws:braket:::device/quantum-simulator/amazon/sv1`
- `arn:aws:braket:us-east-1::device/qpu/ionq/Harmony`
- `arn:aws:braket:us-west-1::device/qpu/rigetti/Aspen-M-3`

**Example:**

```yaml
backend:
  type: ibm_quantum
  name: ibm_brisbane
```

#### `instance` Field

**Optional**. IBM Cloud CRN for enterprise accounts with dedicated access.

**Format:** `crn:v1:bluemix:public:quantum-computing:REGION:a/ACCOUNT_ID:INSTANCE_ID::`

**Example:**

```yaml
backend:
  type: ibm_quantum
  name: ibm_brisbane
  instance: "crn:v1:bluemix:public:quantum-computing:us-east:a/abc123..."
```

### Circuit (`CircuitSpec`)

**Required**. Defines the quantum circuit to execute.

```yaml
circuit:
  source: string            # Required: Source type
  code: string              # For source: inline
  configMapRef:             # For source: configmap
    name: string
    key: string
  url: string               # For source: url
  gitRef:                   # For source: git
    repository: string
    branch: string
    path: string
```

#### `source` Field

**Required**. Circuit source type.

| Value | Description | Use Case |
|-------|-------------|----------|
| `inline` | Embedded in YAML | Small circuits, examples |
| `configmap` | Stored in ConfigMap | Shared circuits |
| `url` | Downloaded from URL | External libraries |
| `git` | Fetched from Git repo | Version control, CI/CD |

#### Inline Source

Embed Qiskit code directly:

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

**Requirements:**
- Valid Python syntax
- Must define variable `qc` of type `QuantumCircuit`
- Can import Qiskit modules

#### ConfigMap Source

Reference a ConfigMap:

```yaml
circuit:
  source: configmap
  configMapRef:
    name: my-circuit
    key: circuit.py
```

**Create ConfigMap:**

```bash
kubectl create configmap my-circuit \
  --from-file=circuit.py=my_algorithm.py
```

#### URL Source

Download from URL:

```yaml
circuit:
  source: url
  url: https://raw.githubusercontent.com/org/repo/main/circuit.py
```

**Requirements:**
- Publicly accessible URL
- Returns valid Python code
- Supports HTTP/HTTPS

#### Git Source

Fetch from Git repository:

```yaml
circuit:
  source: git
  gitRef:
    repository: https://github.com/your-org/quantum-algorithms
    branch: main              # Optional, defaults to default branch
    path: algorithms/grover.py
```

**Authentication:**

For private repositories, create a secret:

```bash
kubectl create secret generic git-credentials \
  --from-literal=username=YOUR_USERNAME \
  --from-literal=password=YOUR_TOKEN
```

Reference in job:

```yaml
spec:
  credentials:
    gitSecretRef:
      name: git-credentials
```

### Execution (`ExecutionSpec`)

**Optional**. Execution parameters.

```yaml
execution:
  shots: integer                # Default: 1024
  optimizationLevel: integer    # Default: 1
  priority: string              # Default: normal
  seedSimulator: integer        # Optional
  initialLayout: [integer]      # Optional
  memoryLimit: string           # Optional
  dynamicCircuits: boolean      # Default: false
  noiseModel: string            # Optional
```

#### `shots` Field

**Type:** `integer`  
**Default:** `1024`  
**Range:** 1 - 100000

Number of circuit executions (measurements).

**Guidelines:**
- **1-100**: Quick tests
- **1024**: Standard experiments
- **4096**: Production
- **8192+**: High precision

**Example:**

```yaml
execution:
  shots: 8192
```

#### `optimizationLevel` Field

**Type:** `integer`  
**Default:** `1`  
**Range:** 0 - 3

Circuit optimization before execution.

| Level | Gates Reduced | Depth Reduced | Use Case |
|-------|---------------|---------------|----------|
| 0 | 0% | 0% | Debugging, testing |
| 1 | ~20% | ~15% | Development |
| 2 | ~40% | ~30% | Production simulator |
| 3 | ~60% | ~50% | Real quantum hardware |

**Example:**

```yaml
execution:
  optimizationLevel: 3
```

#### `priority` Field

**Type:** `string`  
**Default:** `normal`  
**Values:** `low`, `normal`, `high`, `urgent`

Job scheduling priority.

**RBAC Requirements:**
- `low`, `normal`: Default access
- `high`: Requires `quantum:jobs:prioritize`
- `urgent`: Requires `quantum:jobs:urgent`

**Example:**

```yaml
execution:
  priority: high
```

#### `seedSimulator` Field

**Type:** `integer`  
**Optional**

Random seed for simulator (for reproducible results).

**Example:**

```yaml
execution:
  seedSimulator: 42
```

#### `initialLayout` Field

**Type:** `array[integer]`  
**Optional**

Initial qubit mapping to physical qubits.

**Example:**

```yaml
execution:
  initialLayout: [0, 1, 5, 8]  # Map logical qubits to physical
```

#### `memoryLimit` Field

**Type:** `string`  
**Optional**

Memory limit for simulation.

**Example:**

```yaml
execution:
  memoryLimit: "16Gi"
```

### Session (`SessionSpec`)

**Optional**. IBM Quantum Runtime session configuration.

```yaml
session:
  name: string              # Optional: Existing session name
  maxTime: integer          # Optional: Max duration (seconds)
  mode: string              # Optional: Session mode
```

#### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | string | auto-generated | Session name |
| `maxTime` | integer | 3600 | Max duration (seconds) |
| `mode` | string | `batch` | `batch` or `dedicated` |

#### Session Modes

**`batch` Mode:**
- Shared QPU access
- Lower cost
- Higher queue times

**`dedicated` Mode:**
- Exclusive QPU access
- Higher cost  
- Minimal queue times

**Example:**

```yaml
session:
  name: vqe-optimization
  maxTime: 3600
  mode: dedicated
```

**Create Session Resource:**

```yaml
apiVersion: quantum.io/v1
kind: QiskitSession
metadata:
  name: vqe-optimization
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
  maxTime: 3600
  mode: dedicated
```

### Budget (`BudgetSpec`)

**Optional**. Cost constraints.

```yaml
budget:
  maxCost: string           # Maximum cost (e.g., "$10.00")
  costCenter: string        # Cost attribution
  alertThreshold: float     # Alert threshold (0.0-1.0)
```

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| `maxCost` | string | Maximum allowed cost (e.g., "$10.00") |
| `costCenter` | string | Cost center for billing |
| `alertThreshold` | float | Alert when cost reaches this % of max |

**Example:**

```yaml
budget:
  maxCost: "$25.00"
  costCenter: "quantum-research"
  alertThreshold: 0.80
```

### BackendSelection (`BackendSelectionSpec`)

**Optional**. Automatic backend selection preferences.

```yaml
backendSelection:
  weights:
    cost: float             # Weight for cost (0.0-1.0)
    queueTime: float        # Weight for queue time
    capability: float       # Weight for backend capabilities
    availability: float     # Weight for availability
  fallbackToSimulator: boolean
  requirements:
    minQubits: integer
    maxError: float
    maxQueueTime: integer
```

#### Weights

Must sum to 1.0. Each weight is between 0.0 and 1.0.

**Presets:**

```yaml
# Cost-optimized
weights: {cost: 0.70, queueTime: 0.20, capability: 0.05, availability: 0.05}

# Performance-optimized
weights: {cost: 0.05, queueTime: 0.05, capability: 0.70, availability: 0.20}

# Balanced
weights: {cost: 0.25, queueTime: 0.25, capability: 0.25, availability: 0.25}
```

**Example:**

```yaml
backendSelection:
  weights:
    cost: 0.50
    queueTime: 0.30
    capability: 0.15
    availability: 0.05
  fallbackToSimulator: true
  requirements:
    minQubits: 5
    maxError: 0.01
    maxQueueTime: 3600
```

### Output (`OutputSpec`)

**Optional**. Results storage configuration.

```yaml
output:
  type: string              # Storage type
  location: string          # Storage location
  path: string              # Optional: Specific path
  format: string            # Default: json
```

#### `type` Field

**Type:** `string`  
**Default:** `configmap`

| Value | Description | Max Size | Persistence |
|-------|-------------|----------|-------------|
| `configmap` | Kubernetes ConfigMap | 1 MB | Pod lifetime |
| `pvc` | Persistent Volume | Unlimited | Permanent |
| `s3` | S3-compatible storage | Unlimited | Permanent |
| `gcs` | Google Cloud Storage | Unlimited | Permanent |

#### `format` Field

**Type:** `string`  
**Default:** `json`

| Format | Description | Use Case |
|--------|-------------|----------|
| `json` | JSON format | Human-readable, web APIs |
| `pickle` | Python pickle | Python applications |
| `qpy` | Qiskit QPY format | Full circuit serialization |
| `csv` | CSV format | Spreadsheets, analysis |

**Examples:**

```yaml
# ConfigMap
output:
  type: configmap
  location: my-results
  format: json

# PVC
output:
  type: pvc
  location: quantum-results-pvc
  path: /results/job-123.json
  format: json

# S3
output:
  type: s3
  location: s3://my-bucket/results/
  format: json

# GCS
output:
  type: gcs
  location: gs://my-bucket/results/
  format: json
```

### Resources (`ResourceRequirements`)

**Optional**. Pod resource requirements.

```yaml
resources:
  requests:
    cpu: string
    memory: string
    ephemeral-storage: string
  limits:
    cpu: string
    memory: string
    ephemeral-storage: string
```

**Example:**

```yaml
resources:
  requests:
    cpu: "2"
    memory: "8Gi"
    ephemeral-storage: "10Gi"
  limits:
    cpu: "8"
    memory: "32Gi"
    ephemeral-storage: "50Gi"
```

**Guidelines:**

| Qubits | CPU | Memory |
|--------|-----|--------|
| <10 | 1 | 2-4 Gi |
| 10-20 | 2-4 | 8-16 Gi |
| 20-30 | 8+ | 32-64 Gi |
| 30+ | 16+ | 128+ Gi |

### Credentials (`CredentialsSpec`)

**Optional**. Authentication credentials.

```yaml
credentials:
  secretRef:
    name: string
  gitSecretRef:
    name: string
```

**Example:**

```yaml
credentials:
  secretRef:
    name: ibm-quantum-credentials
```

**Create Secret:**

```bash
kubectl create secret generic ibm-quantum-credentials \
  --from-literal=api-key=YOUR_IBM_QUANTUM_API_KEY
```

### RetryPolicy

**Optional**. Automatic retry configuration.

```yaml
retryPolicy:
  maxRetries: integer       # Default: 0 (no retries)
  backoff:
    initial: duration       # Initial backoff (e.g., "30s")
    maximum: duration       # Max backoff (e.g., "5m")
    multiplier: float       # Backoff multiplier (e.g., 2.0)
```

**Example:**

```yaml
retryPolicy:
  maxRetries: 3
  backoff:
    initial: 30s
    maximum: 300s
    multiplier: 2
```

### Timeouts

**Optional**. Execution timeouts.

```yaml
timeouts:
  validation: duration      # Validation timeout
  execution: duration       # Execution timeout
  total: duration           # Total job timeout
```

**Example:**

```yaml
timeouts:
  validation: 60s
  execution: 3600s
  total: 7200s
```

### SecurityContext

**Optional**. Pod security context.

```yaml
securityContext:
  runAsNonRoot: boolean
  runAsUser: integer
  fsGroup: integer
  seccompProfile:
    type: string
  capabilities:
    drop: [string]
```

**Example:**

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 2000
  seccompProfile:
    type: RuntimeDefault
  capabilities:
    drop:
      - ALL
```

## Status Fields

The operator updates these fields as the job progresses.

```yaml
status:
  phase: string                 # Current phase
  startTime: timestamp          # Job start time
  completionTime: timestamp     # Job completion time
  cost: string                  # Total cost
  backend: string               # Selected backend
  queueTime: integer            # Time in queue (seconds)
  executionTime: integer        # Execution time (seconds)
  circuitMetrics:               # Circuit information
    qubits: integer
    depth: integer
    gates: integer
    hash: string
  conditions: [Condition]       # Status conditions
  message: string               # Human-readable message
  executorPodName: string       # Executor pod name
  resultsLocation: string       # Where results are stored
```

### Phase Values

| Phase | Description |
|-------|-------------|
| `Pending` | Job created, waiting for processing |
| `Validating` | Circuit validation in progress |
| `Scheduling` | Backend selection and pod scheduling |
| `Running` | Circuit execution in progress |
| `Completed` | Job completed successfully |
| `Failed` | Job failed (see conditions for details) |

### Conditions

Array of condition objects:

```yaml
conditions:
  - type: string              # Condition type
    status: string            # "True", "False", or "Unknown"
    lastTransitionTime: timestamp
    reason: string            # Machine-readable reason
    message: string           # Human-readable message
```

**Condition Types:**
- `Validated`: Circuit validation status
- `BudgetChecked`: Budget verification status
- `BackendSelected`: Backend selection status
- `PodCreated`: Executor pod creation status
- `Executed`: Execution status
- `ResultsStored`: Results storage status

## Complete Example

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: production-vqe
  namespace: quantum-chemistry
  labels:
    app: qiskit-operator
    algorithm: vqe
    molecule: h2
    environment: production
    team: quantum-research
  annotations:
    description: "VQE calculation for H2 molecule ground state"
    jira: "QUANT-123"
    owner: "alice@example.com"

spec:
  # Backend configuration
  backend:
    type: ibm_quantum
    name: ibm_brisbane
    instance: "crn:v1:bluemix:public:quantum-computing:us-east:..."
  
  # Circuit from Git
  circuit:
    source: git
    gitRef:
      repository: https://github.com/our-org/quantum-chemistry
      branch: production
      path: vqe/h2_molecule.py
  
  # Execution parameters
  execution:
    shots: 8192
    optimizationLevel: 3
    priority: high
    seedSimulator: 42
  
  # Session for multiple iterations
  session:
    name: vqe-h2-session
    maxTime: 3600
    mode: dedicated
  
  # Budget constraints
  budget:
    maxCost: "$50.00"
    costCenter: "chemistry-dept"
    alertThreshold: 0.80
  
  # Backend selection
  backendSelection:
    weights:
      cost: 0.30
      queueTime: 0.30
      capability: 0.30
      availability: 0.10
    fallbackToSimulator: false
    requirements:
      minQubits: 2
      maxError: 0.01
      maxQueueTime: 1800
  
  # Output to S3
  output:
    type: s3
    location: s3://quantum-results/vqe/h2/
    format: json
  
  # Resource requirements
  resources:
    requests:
      cpu: "2"
      memory: "8Gi"
      ephemeral-storage: "10Gi"
    limits:
      cpu: "8"
      memory: "32Gi"
      ephemeral-storage: "50Gi"
  
  # Credentials
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  # Retry policy
  retryPolicy:
    maxRetries: 3
    backoff:
      initial: 60s
      maximum: 600s
      multiplier: 2
  
  # Timeouts
  timeouts:
    validation: 120s
    execution: 3600s
    total: 7200s
  
  # Security context
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
        - ALL
```

## Field Validation

### Kubebuilder Markers

The QiskitJob CRD uses Kubebuilder markers for validation:

```go
// Backend type validation
// +kubebuilder:validation:Enum=ibm_quantum;ibm_simulator;aws_braket;local_simulator
Type string `json:"type"`

// Shots validation
// +kubebuilder:validation:Minimum=1
// +kubebuilder:validation:Maximum=100000
// +kubebuilder:default=1024
Shots int `json:"shots,omitempty"`

// Optimization level validation
// +kubebuilder:validation:Minimum=0
// +kubebuilder:validation:Maximum=3
// +kubebuilder:default=1
OptimizationLevel int `json:"optimizationLevel,omitempty"`
```

## kubectl Commands

### Create Job

```bash
kubectl apply -f qiskitjob.yaml
```

### Get Job

```bash
kubectl get qiskitjob my-job
kubectl get qiskitjob my-job -o yaml
kubectl get qiskitjob my-job -o json
```

### Describe Job

```bash
kubectl describe qiskitjob my-job
```

### Get Job Phase

```bash
kubectl get qiskitjob my-job -o jsonpath='{.status.phase}'
```

### Get Job Cost

```bash
kubectl get qiskitjob my-job -o jsonpath='{.status.cost}'
```

### List Jobs

```bash
kubectl get qiskitjobs
kubectl get qiskitjobs -A  # All namespaces
kubectl get qiskitjobs -l algorithm=vqe  # Filter by label
```

### Watch Job

```bash
kubectl get qiskitjob my-job -w
```

### Delete Job

```bash
kubectl delete qiskitjob my-job
kubectl delete qiskitjobs --all  # Delete all jobs
```

## Next Steps

- [QiskitBackend Reference](qiskitbackend.md)
- [QiskitSession Reference](qiskitsession.md)
- [QiskitBudget Reference](qiskitbudget.md)
- [User Guide](../user-guide/quantum-jobs.md)

