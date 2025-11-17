# IBM Quantum Backend

Connect Qiskit Operator to IBM Quantum Platform to access real quantum hardware and cloud simulators.

## Overview

IBM Quantum provides access to:
- **Real quantum processors** (100+ qubits)
- **Cloud-based simulators** (up to 32 qubits)
- **IBM Quantum Runtime** for optimized execution
- **Sessions** for iterative algorithms

## Prerequisites

### 1. Create IBM Quantum Account

Sign up for free at [quantum.ibm.com](https://quantum.ibm.com/)

**Free Tier Includes:**
- Access to all simulators
- 10 minutes/month of quantum hardware time
- Priority queue access for students/researchers

### 2. Get API Key

1. Log in to [quantum.ibm.com](https://quantum.ibm.com/)
2. Navigate to **Account Settings**
3. Copy your API token

## Setup

### Create Kubernetes Secret

```bash
kubectl create secret generic ibm-quantum-credentials \
  --from-literal=api-key=YOUR_IBM_QUANTUM_API_KEY \
  --namespace default
```

For multiple namespaces:

```bash
# Create in each namespace
for ns in default production research; do
  kubectl create secret generic ibm-quantum-credentials \
    --from-literal=api-key=YOUR_IBM_QUANTUM_API_KEY \
    --namespace $ns
done
```

### Verify Credentials

```yaml title="test-ibm-connection.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: test-ibm-connection
spec:
  backend:
    type: ibm_quantum
    name: ibm_simulator  # Free simulator
  
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
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  output:
    type: configmap
    location: ibm-test-results
```

Apply and verify:

```bash
kubectl apply -f test-ibm-connection.yaml
kubectl get qiskitjob test-ibm-connection -w
kubectl get configmap ibm-test-results -o yaml
```

## Available Backends

### Simulators (Free)

| Backend | Qubits | Cost | Description |
|---------|--------|------|-------------|
| `ibm_simulator` | 32 | Free | Cloud-based simulator |
| `simulator_statevector` | 32 | Free | Statevector simulator |
| `simulator_stabilizer` | 5000 | Free | Clifford circuit simulator |

### Quantum Hardware (Paid)

| Backend | Qubits | Quantum Volume | Region | Cost |
|---------|--------|----------------|--------|------|
| `ibm_brisbane` | 127 | 256 | US East | $1.60/min |
| `ibm_kyoto` | 127 | 256 | Asia | $1.60/min |
| `ibm_osaka` | 127 | 256 | Asia | $1.60/min |
| `ibm_sherbrooke` | 127 | 256 | Canada | $1.60/min |

*Pricing as of 2025. Check [IBM Quantum Pricing](https://www.ibm.com/quantum/pricing) for latest.*

### Check Available Backends

```python
from qiskit_ibm_runtime import QiskitRuntimeService

service = QiskitRuntimeService(channel="ibm_quantum", token="YOUR_API_KEY")

# List all backends
backends = service.backends()
for backend in backends:
    print(f"{backend.name}: {backend.num_qubits} qubits, status={backend.status().status_msg}")
```

## Configuration Examples

### Basic Simulator Job

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: ibm-simulator-job
spec:
  backend:
    type: ibm_quantum
    name: ibm_simulator
  
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      qc = QuantumCircuit(5, 5)
      qc.h(range(5))
      qc.measure_all()
  
  execution:
    shots: 8192
    optimizationLevel: 3
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  output:
    type: configmap
    location: simulator-results
```

### Quantum Hardware Job

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: hardware-job
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
  
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      
      # Grover's algorithm for 3 qubits
      qc = QuantumCircuit(3, 3)
      
      # Initialize
      qc.h([0, 1, 2])
      
      # Oracle (mark |111⟩)
      qc.h(2)
      qc.ccx(0, 1, 2)
      qc.h(2)
      
      # Diffusion
      qc.h([0, 1, 2])
      qc.x([0, 1, 2])
      qc.h(2)
      qc.ccx(0, 1, 2)
      qc.h(2)
      qc.x([0, 1, 2])
      qc.h([0, 1, 2])
      
      qc.measure([0, 1, 2], [0, 1, 2])
  
  execution:
    shots: 8192
    optimizationLevel: 3
  
  budget:
    maxCost: "$50.00"
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  output:
    type: s3
    location: s3://quantum-results/hardware/grover
    format: json
```

### Enterprise Instance

For IBM Quantum Network Premium members:

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: enterprise-job
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
    instance: "crn:v1:bluemix:public:quantum-computing:us-east:a/xxx:xxx::"
    # Or legacy format:
    # hub: ibm-q-internal
    # group: deployed
    # project: default
  
  circuit:
    source: git
    gitRef:
      repository: https://github.com/your-org/quantum-circuits
      branch: main
      path: production/circuit.py
  
  execution:
    shots: 16384
    optimizationLevel: 3
    priority: high
  
  credentials:
    secretRef:
      name: ibm-quantum-enterprise-credentials
  
  output:
    type: pvc
    location: quantum-results-pvc
    format: pickle
```

## Sessions

IBM Quantum Runtime sessions enable iterative algorithms like VQE and QAOA.

### Create Session

```yaml
apiVersion: quantum.io/v1
kind: QiskitSession
metadata:
  name: vqe-session
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
  
  maxTime: 3600  # 1 hour
  mode: dedicated  # or 'shared'
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
```

### Use Session in Job

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: vqe-iteration-1
spec:
  backend:
    type: ibm_quantum
  
  session:
    name: vqe-session
  
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      # VQE ansatz circuit
      qc = QuantumCircuit(4)
      # ... circuit definition
  
  execution:
    shots: 4096
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
```

**Session Benefits:**
- Reduced queue time for multiple jobs
- Lower cost per job
- Guaranteed access to same backend
- Ideal for iterative algorithms

## Cost Management

### Budget Controls

```yaml
apiVersion: quantum.io/v1
kind: QiskitBudget
metadata:
  name: ibm-quantum-budget
  namespace: default
spec:
  limit: "$500.00"
  period: monthly
  
  backends:
    - type: ibm_quantum
      maxCostPerJob: "$20.00"
  
  alerts:
    - threshold: 75
      channels: ["slack", "email"]
    - threshold: 90
      channels: ["slack", "email", "pagerduty"]
  
  costAllocation:
    costCenter: quantum-research
    project: drug-discovery
```

### Cost-Optimized Backend Selection

```yaml
spec:
  backend:
    type: ibm_quantum  # Don't specify name
  
  backendSelection:
    weights:
      cost: 0.70          # Prioritize cost
      queueTime: 0.15
      capability: 0.10
      availability: 0.05
    
    fallbackToSimulator: true
    
    constraints:
      minQubits: 27
      maxQueueTime: 1800  # 30 minutes
```

### View Job Cost

```bash
kubectl get qiskitjob my-job -o jsonpath='{.status.cost}'
```

## Backend Selection

### Automatic Selection

Let the operator choose the best backend:

```yaml
spec:
  backend:
    type: ibm_quantum
  
  backendSelection:
    weights:
      cost: 0.50
      queueTime: 0.30
      capability: 0.15
      availability: 0.05
```

### Manual Selection

Specify a particular backend:

```yaml
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
```

### Fallback Strategy

```yaml
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
  
  backendSelection:
    fallbackToSimulator: true  # Use simulator if hardware unavailable
    maxQueueTime: 1800         # Wait max 30 minutes
```

## Optimization Levels

| Level | Description | Transpilation Time | Circuit Quality |
|-------|-------------|-------------------|-----------------|
| **0** | No optimization | Fast | Basic |
| **1** | Light optimization | Fast | Good |
| **2** | Medium optimization | Moderate | Better |
| **3** | Heavy optimization | Slow | Best |

Recommendation:
- **Level 1**: Testing and development
- **Level 2**: Standard production workloads
- **Level 3**: Critical jobs, maximum fidelity needed

```yaml
execution:
  optimizationLevel: 3  # Heavy optimization for hardware
```

## Error Mitigation

IBM Quantum Runtime includes built-in error mitigation:

```yaml
execution:
  errorMitigation:
    enabled: true
    method: "resilience_level_1"  # or resilience_level_2, resilience_level_3
```

**Resilience Levels:**
- **Level 1**: Zero-noise extrapolation
- **Level 2**: Probabilistic error cancellation
- **Level 3**: Advanced error suppression

## Monitoring

### View Backend Status

```bash
# Create backend resource
kubectl apply -f - <<EOF
apiVersion: quantum.io/v1
kind: QiskitBackend
metadata:
  name: ibm-brisbane-backend
spec:
  type: ibm_quantum
  name: ibm_brisbane
  credentials:
    secretRef:
      name: ibm-quantum-credentials
EOF

# Check status
kubectl get qiskitbackend ibm-brisbane-backend -o yaml
```

### Metrics

```bash
# Prometheus metrics
kubectl port-forward -n qiskit-operator-system svc/qiskit-operator-metrics 8080:8080

# Query IBM Quantum metrics
curl http://localhost:8080/metrics | grep ibm_quantum
```

**Available Metrics:**
- `qiskit_ibm_queue_time_seconds`
- `qiskit_ibm_execution_time_seconds`
- `qiskit_ibm_job_cost_dollars`
- `qiskit_ibm_backend_availability`

## Troubleshooting

### Authentication Errors

```bash
# Verify secret exists
kubectl get secret ibm-quantum-credentials -o yaml

# Test credentials manually
python3 << EOF
from qiskit_ibm_runtime import QiskitRuntimeService
service = QiskitRuntimeService(channel="ibm_quantum", token="YOUR_TOKEN")
print("Backends:", [b.name for b in service.backends()])
EOF
```

### Job Stuck in Queue

```bash
# Check job status
kubectl describe qiskitjob my-job

# View queue time
kubectl get qiskitjob my-job -o jsonpath='{.status.queueTime}'
```

**Solutions:**
- Use `fallbackToSimulator: true`
- Set `maxQueueTime` limit
- Choose less busy backend
- Use IBM Quantum Runtime sessions

### Budget Exceeded

```yaml
status:
  phase: Failed
  conditions:
    - type: BudgetExceeded
      status: "True"
      message: "Estimated cost $25.00 exceeds budget $20.00"
```

**Solutions:**
- Increase budget limit
- Enable `fallbackToSimulator`
- Reduce number of shots
- Use simulator for testing

### Rate Limiting

IBM Quantum enforces rate limits:
- **Free tier**: 5 jobs/minute
- **Premium**: 100 jobs/minute

Configure retry backoff:

```yaml
execution:
  maxRetries: 5
  retryBackoff: exponential
```

## Best Practices

### 1. Test on Simulator First

```bash
# Always test on simulator before hardware
kubectl apply -f job-simulator.yaml
# Verify results, then run on hardware
kubectl apply -f job-hardware.yaml
```

### 2. Use Sessions for Iterative Algorithms

For VQE, QAOA, etc., use sessions to reduce cost and queue time.

### 3. Set Appropriate Optimization Levels

Higher levels take longer but produce better circuits for hardware.

### 4. Monitor Costs

```bash
# Set up budget alerts
kubectl apply -f budget.yaml

# Regularly check spending
kubectl get qiskitjobs -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.cost}{"\n"}{end}'
```

### 5. Use Cost-Optimized Selection

Let the operator choose the cheapest available backend.

## Pricing

### Simulator
- **Free** for all users

### Quantum Hardware

**IBM Quantum Premium:**
- $1.60/minute of QPU time
- Billed per second
- Minimum charge: $0.027 (1 second)

**Example Costs:**
```
1024 shots × 5-qubit circuit ≈ 10 seconds ≈ $0.27
8192 shots × 10-qubit circuit ≈ 60 seconds ≈ $1.60
```

**Sessions:**
- Same per-second rate
- Exclusive access to QPU
- Lower effective cost for multiple jobs

### Cost Calculator

```python
def estimate_cost(shots, qubits, depth, backend="ibm_brisbane"):
    # Rough estimate
    base_time = 0.001  # 1ms per shot
    circuit_factor = (qubits * depth) / 100
    total_time = shots * base_time * circuit_factor
    
    if "simulator" in backend:
        return 0.0
    
    rate = 1.60 / 60  # $1.60 per minute
    return total_time * rate

print(f"Estimated cost: ${estimate_cost(8192, 5, 10):.2f}")
```

## Additional Resources

- [IBM Quantum Documentation](https://quantum.ibm.com/docs)
- [Qiskit Runtime Documentation](https://qiskit.org/ecosystem/ibm-runtime/)
- [IBM Quantum Pricing](https://www.ibm.com/quantum/pricing)
- [IBM Quantum Blog](https://www.ibm.com/quantum/blog)
- [Qiskit Slack](https://qiskit.slack.com)

## Next Steps

- [AWS Braket Backend](aws-braket.md)
- [Local Simulator](local-simulator.md)
- [Backend Selection](selection.md)
- [Cost Comparison](cost-comparison.md)

