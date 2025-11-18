# Tutorial: Creating a Bell State

## Overview

In this tutorial, you'll learn how to create and execute a Bell state (maximally entangled quantum state) using QiskitOperator. This is the perfect starting point for quantum computing on Kubernetes.

## What is a Bell State?

A Bell state is a maximally entangled quantum state of two qubits. The most common Bell state is:

$$
|\Phi^+\rangle = \frac{|00\rangle + |11\rangle}{\sqrt{2}}
$$

When measured, this state produces either `00` or `11` with equal probability (50% each), demonstrating quantum entanglement where the qubits are perfectly correlated.

## Prerequisites

- QiskitOperator installed on your Kubernetes cluster
- `kubectl` configured to access your cluster
- Basic understanding of quantum circuits

## Step 1: Understanding the Circuit

The Bell state circuit consists of just two gates:

1. **Hadamard (H) gate**: Creates superposition on the first qubit
2. **CNOT (CX) gate**: Entangles the two qubits

```python
from qiskit import QuantumCircuit

# Create a 2-qubit circuit with 2 classical bits for measurement
qc = QuantumCircuit(2, 2)

# Apply Hadamard gate to qubit 0 (creates superposition)
qc.h(0)

# Apply CNOT gate with qubit 0 as control and qubit 1 as target
# This creates entanglement
qc.cx(0, 1)

# Measure both qubits
qc.measure([0, 1], [0, 1])
```

### Circuit Visualization

```
     ┌───┐     ┌─┐   
q_0: ┤ H ├──■──┤M├───
     └───┘┌─┴─┐└╥┘┌─┐
q_1: ─────┤ X ├─╫─┤M├
          └───┘ ║ └╥┘
c: 2/═══════════╩══╩═
                0  1 
```

## Step 2: Create the QiskitJob Resource

Create a file named `bell-state-job.yaml`:

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: bell-state-tutorial
  namespace: default
  labels:
    tutorial: bell-state
    app: qiskit-operator
spec:
  # Use local simulator for testing (no quantum hardware required)
  backend:
    type: local_simulator
  
  # Circuit definition (inline Qiskit code)
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      
      # Create a 2-qubit Bell state (maximally entangled state)
      qc = QuantumCircuit(2, 2)
      
      # Apply Hadamard gate to first qubit
      qc.h(0)
      
      # Apply CNOT gate
      qc.cx(0, 1)
      
      # Measure both qubits
      qc.measure([0, 1], [0, 1])
  
  # Execution parameters
  execution:
    shots: 1024              # Number of measurements
    optimizationLevel: 1     # Circuit optimization (0-3)
    priority: normal         # Job priority
  
  # Store results in a ConfigMap
  output:
    type: configmap
    location: bell-state-results
    format: json
  
  # Resource requirements for the executor pod
  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "2"
      memory: "4Gi"
```

## Step 3: Submit the Job

Apply the job to your Kubernetes cluster:

```bash
kubectl apply -f bell-state-job.yaml
```

Expected output:
```
qiskitjob.quantum.io/bell-state-tutorial created
```

## Step 4: Monitor Job Execution

Watch the job progress through its lifecycle:

```bash
kubectl get qiskitjob bell-state-tutorial -w
```

You'll see the job transition through phases:

```
NAME                  PHASE        BACKEND           COST     AGE
bell-state-tutorial   Pending      local_simulator   $0.00    1s
bell-state-tutorial   Validating   local_simulator   $0.00    2s
bell-state-tutorial   Scheduling   local_simulator   $0.00    3s
bell-state-tutorial   Running      local_simulator   $0.00    5s
bell-state-tutorial   Completed    local_simulator   $0.00    28s
```

### Check Detailed Status

Get comprehensive status information:

```bash
kubectl describe qiskitjob bell-state-tutorial
```

Output includes:
- Circuit validation results
- Backend selection details
- Execution pod status
- Cost information
- Error messages (if any)

## Step 5: View the Results

### Option 1: Read the ConfigMap

```bash
kubectl get configmap bell-state-results -o yaml
```

### Option 2: Extract and Pretty-Print Results

```bash
kubectl get configmap bell-state-results -o jsonpath='{.data.results}' | jq
```

### Expected Results

You should see results similar to:

```json
{
  "counts": {
    "00": 512,
    "11": 512
  },
  "metadata": {
    "shots": 1024,
    "qubits": 2,
    "depth": 3,
    "gates": 4
  },
  "execution_time": 1.23,
  "backend": "local_simulator"
}
```

The results show approximately 50% `00` and 50% `11`, confirming the Bell state entanglement!

## Step 6: View Execution Logs

Check the executor pod logs for detailed execution information:

```bash
# Find the pod name
kubectl get pods -l job-name=bell-state-tutorial

# View logs
kubectl logs qiskit-job-bell-state-tutorial
```

Sample log output:

```
[INFO] Starting quantum circuit execution
[INFO] Circuit validation: PASSED
[INFO] Qubits: 2, Depth: 3, Gates: 4
[INFO] Backend: local_simulator
[INFO] Executing circuit with 1024 shots...
[INFO] Execution completed in 1.23s
[INFO] Results: {'00': 512, '11': 512}
[INFO] Storing results in ConfigMap: bell-state-results
[INFO] Job completed successfully
```

## Understanding the Results

### Entanglement Verification

The 50/50 split between `00` and `11` (with no `01` or `10`) proves quantum entanglement:

- **Classical correlation**: Would produce all four outcomes
- **Quantum entanglement**: Only produces `00` and `11`
- **Perfect correlation**: Measuring qubit 0 instantly determines qubit 1's state

### Statistical Analysis

With 1024 shots, expect some statistical variation:

```python
# Theoretical: 50% each
# Actual example: 
#   00: 512 (50.0%)
#   11: 512 (50.0%)
#
# This is within expected statistical bounds
```

## Advanced: Using Real Quantum Hardware

To run on IBM Quantum hardware:

### 1. Create IBM Quantum Credentials Secret

```bash
kubectl create secret generic ibm-quantum-credentials \
  --from-literal=api-key=YOUR_IBM_QUANTUM_API_KEY \
  --namespace default
```

### 2. Update the Job Specification

```yaml
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane  # or any available backend
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  budget:
    maxCost: "$1.00"  # Set a budget limit
```

### 3. Submit and Monitor

```bash
kubectl apply -f bell-state-job.yaml
kubectl get qiskitjob bell-state-tutorial -w
```

Note: Real quantum hardware may take longer due to queue times and will have noise affecting results.

## Cleanup

Delete the job and results:

```bash
# Delete the job
kubectl delete qiskitjob bell-state-tutorial

# Delete the results ConfigMap
kubectl delete configmap bell-state-results
```

## Next Steps

Now that you've successfully created a Bell state, try these next tutorials:

- [Quantum Teleportation](quantum-teleportation.md) - Use entanglement for quantum communication
- [Grover's Algorithm](grovers-algorithm.md) - Quantum search with quadratic speedup
- [VQE for Chemistry](vqe-chemistry.md) - Find molecular ground states

## Common Issues

### Job Stuck in Pending

**Problem**: Job doesn't progress past `Pending` phase.

**Solution**: Check operator logs:
```bash
kubectl logs -n qiskit-operator-system deployment/qiskit-operator-controller
```

### Circuit Validation Failed

**Problem**: Job fails with validation errors.

**Solution**: Ensure your circuit code is valid Qiskit syntax. Test locally first:
```bash
cd validation-service
python test_simple_example.py
```

### Pod ImagePullBackOff

**Problem**: Executor pod can't pull the image.

**Solution**: For local clusters (Kind/Minikube), load the image:
```bash
kind load docker-image qiskit-executor:v1 --name your-cluster
```

## Summary

In this tutorial, you learned to:

✅ Create a Bell state quantum circuit  
✅ Define it as a QiskitJob resource  
✅ Submit and monitor quantum job execution  
✅ Retrieve and interpret results  
✅ Verify quantum entanglement  
✅ Use both local simulators and real quantum hardware  

Congratulations! You've successfully run your first quantum circuit on Kubernetes! 🎉

## Additional Resources

- [Qiskit Textbook: Bell States](https://qiskit.org/textbook/ch-gates/multiple-qubits-entangled-states.html)
- [QiskitJob API Reference](../reference/qiskitjob.md)
- [Backend Configuration Guide](../user-guide/backends.md)
- [All Circuit Examples](../examples/README.md)

