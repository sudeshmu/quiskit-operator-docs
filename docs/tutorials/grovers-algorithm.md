# Tutorial: Grover's Search Algorithm

## Overview

Learn how to implement Grover's quantum search algorithm using QiskitOperator. Grover's algorithm provides a quadratic speedup for searching unsorted databases, finding marked items in O(√N) time compared to O(N) classically.

## What is Grover's Algorithm?

Grover's algorithm is a quantum algorithm for searching an unsorted database or solving the unstructured search problem. Given N items with one marked item, Grover's algorithm finds it in approximately √N queries.

### Key Components

1. **Superposition**: Initialize all qubits in equal superposition
2. **Oracle**: Mark the target state(s) by flipping their phase
3. **Diffusion Operator**: Amplify the amplitude of marked states
4. **Iteration**: Repeat oracle + diffusion ~√N times

### Example: Finding |101⟩

For a 3-qubit system (8 possible states), finding state `|101⟩` requires:
- **Classical**: 4 queries on average (worst case: 8)
- **Grover's**: ~2 queries (√8 ≈ 2.83)

## The Algorithm

### Mathematical Foundation

For an N-item database with M marked items:

$$
\text{Optimal iterations} = \frac{\pi}{4}\sqrt{\frac{N}{M}}
$$

For our example (N=8, M=1):

$$
\text{Iterations} = \frac{\pi}{4}\sqrt{8} \approx 2
$$

## Step-by-Step Implementation

### Step 1: Understand the Circuit

```python
from qiskit import QuantumCircuit
import math

# Create 3-qubit circuit for searching
qc = QuantumCircuit(3, 3)

# Initialize: Create equal superposition
qc.h([0, 1, 2])
qc.barrier()

# Calculate optimal number of iterations
n_qubits = 3
optimal_iterations = int(math.pi/4 * math.sqrt(2**n_qubits))  # = 2

# Grover iterations
for iteration in range(optimal_iterations):
    # Oracle: Mark the state |101⟩
    qc.x(1)  # Flip middle qubit (so we're looking for |111⟩)
    qc.h(2)
    qc.ccx(0, 1, 2)  # Toffoli gate
    qc.h(2)
    qc.x(1)  # Flip back
    
    qc.barrier()
    
    # Diffusion operator (inversion about average)
    qc.h([0, 1, 2])
    qc.x([0, 1, 2])
    qc.h(2)
    qc.ccx(0, 1, 2)
    qc.h(2)
    qc.x([0, 1, 2])
    qc.h([0, 1, 2])
    
    qc.barrier()

# Measure all qubits
qc.measure([0, 1, 2], [0, 1, 2])
```

### Circuit Breakdown

#### 1. Initialization Phase
```
     ┌───┐
q_0: ┤ H ├  → Creates |+⟩ = (|0⟩ + |1⟩)/√2
     ├───┤
q_1: ┤ H ├  → All qubits in superposition
     ├───┤
q_2: ┤ H ├  → Total state: Σ|xyz⟩/√8
     └───┘
```

#### 2. Oracle Phase
Marks target state by flipping its phase: |101⟩ → -|101⟩

#### 3. Diffusion Phase  
Amplifies marked state amplitude through inversion about the mean

## Step 2: Create the QiskitJob

Create `grover-search.yaml`:

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: grover-search-101
  namespace: default
  labels:
    algorithm: grover
    difficulty: intermediate
spec:
  backend:
    type: local_simulator
  
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      import math
      
      # Create 3-qubit circuit for searching
      qc = QuantumCircuit(3, 3)
      
      # Initialize: Create equal superposition
      qc.h([0, 1, 2])
      qc.barrier()
      
      # Calculate optimal number of iterations: π/4 * sqrt(2^n)
      n_qubits = 3
      optimal_iterations = int(math.pi/4 * math.sqrt(2**n_qubits))
      
      # Grover iterations
      for iteration in range(optimal_iterations):
          # Oracle: Mark the state |101⟩
          # Flip phase of |101⟩
          qc.x(1)  # Flip middle qubit (so we're looking for |111⟩)
          qc.h(2)
          qc.ccx(0, 1, 2)  # Toffoli gate
          qc.h(2)
          qc.x(1)  # Flip back
          
          qc.barrier()
          
          # Diffusion operator (inversion about average)
          qc.h([0, 1, 2])
          qc.x([0, 1, 2])
          qc.h(2)
          qc.ccx(0, 1, 2)
          qc.h(2)
          qc.x([0, 1, 2])
          qc.h([0, 1, 2])
          
          qc.barrier()
      
      # Measure all qubits
      qc.measure([0, 1, 2], [0, 1, 2])
  
  execution:
    shots: 2048
    optimizationLevel: 2
    priority: normal
  
  output:
    type: configmap
    location: grover-search-results
    format: json
  
  resources:
    requests:
      cpu: "1"
      memory: "2Gi"
    limits:
      cpu: "4"
      memory: "8Gi"
```

## Step 3: Submit and Monitor

```bash
# Apply the job
kubectl apply -f grover-search.yaml

# Monitor progress
kubectl get qiskitjob grover-search-101 -w

# Check detailed status
kubectl describe qiskitjob grover-search-101
```

## Step 4: Analyze Results

```bash
# Get results
kubectl get configmap grover-search-results -o jsonpath='{.data.results}' | jq
```

### Expected Results

With perfect amplitude amplification, you should see ~95%+ probability for |101⟩:

```json
{
  "counts": {
    "000": 5,
    "001": 8,
    "010": 12,
    "011": 6,
    "100": 10,
    "101": 1950,  ← Target state!
    "110": 9,
    "111": 48
  },
  "success_probability": 0.952,
  "metadata": {
    "shots": 2048,
    "qubits": 3,
    "depth": 47,
    "gates": 89,
    "grover_iterations": 2
  }
}
```

### Success Probability

$$
P(\text{target}) = \sin^2\left((2k+1)\theta\right)
$$

where:
- k = number of iterations
- θ = arcsin(√(M/N))

For our example: P ≈ 0.95 (95%)

## Visualization Script

Create a Python script to visualize results:

```python
#!/usr/bin/env python3
import json
import matplotlib.pyplot as plt
import subprocess

# Get results from ConfigMap
result = subprocess.check_output([
    'kubectl', 'get', 'configmap', 'grover-search-results',
    '-o', 'jsonpath={.data.results}'
])

data = json.loads(result)
counts = data['counts']

# Sort by state
states = sorted(counts.keys())
values = [counts[s] for s in states]

# Create bar chart
plt.figure(figsize=(12, 6))
bars = plt.bar(states, values)

# Highlight target state
target_idx = states.index('101')
bars[target_idx].set_color('red')

plt.xlabel('Quantum State')
plt.ylabel('Count')
plt.title('Grover\'s Algorithm Results - Searching for |101⟩')
plt.axhline(y=2048/8, color='gray', linestyle='--', label='Uniform distribution')
plt.legend()
plt.grid(axis='y', alpha=0.3)
plt.savefig('grover-results.png', dpi=300, bbox_inches='tight')
print("Results saved to grover-results.png")
```

## Advanced: Multiple Target States

Search for multiple states (e.g., |101⟩ and |110⟩):

```yaml
spec:
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      import math
      
      qc = QuantumCircuit(3, 3)
      qc.h([0, 1, 2])
      qc.barrier()
      
      # For 2 marked items out of 8
      n_qubits = 3
      marked_items = 2
      total_items = 2**n_qubits
      optimal_iterations = int(math.pi/4 * math.sqrt(total_items/marked_items))
      
      for _ in range(optimal_iterations):
          # Oracle for |101⟩
          qc.x(1)
          qc.h(2)
          qc.ccx(0, 1, 2)
          qc.h(2)
          qc.x(1)
          
          # Oracle for |110⟩
          qc.x(0)
          qc.h(2)
          qc.ccx(0, 1, 2)
          qc.h(2)
          qc.x(0)
          
          qc.barrier()
          
          # Diffusion operator
          qc.h([0, 1, 2])
          qc.x([0, 1, 2])
          qc.h(2)
          qc.ccx(0, 1, 2)
          qc.h(2)
          qc.x([0, 1, 2])
          qc.h([0, 1, 2])
          
          qc.barrier()
      
      qc.measure([0, 1, 2], [0, 1, 2])
```

## Running on Real Quantum Hardware

### Setup IBM Quantum Credentials

```bash
kubectl create secret generic ibm-quantum-credentials \
  --from-literal=api-key=YOUR_IBM_QUANTUM_API_KEY
```

### Update Job Specification

```yaml
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane  # Choose a backend with ≥3 qubits
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  execution:
    shots: 8192  # More shots for real hardware (noise)
    optimizationLevel: 3  # Maximum optimization
  
  budget:
    maxCost: "$5.00"
```

### Expected Results on Real Hardware

Real quantum computers have noise, so expect lower success rates:

```json
{
  "counts": {
    "101": 6500,  ← Still dominant, but lower %
    "others": 1692
  },
  "success_probability": 0.79,  ← Reduced due to noise
  "backend": "ibm_brisbane"
}
```

## Performance Comparison

| Search Method | Queries Needed | Complexity |
|---------------|----------------|------------|
| Classical (worst case) | 8 | O(N) |
| Classical (average) | 4 | O(N/2) |
| **Grover's Algorithm** | **2** | **O(√N)** |

For larger search spaces:

| Database Size (N) | Classical | Grover's | Speedup |
|-------------------|-----------|----------|---------|
| 16 | 8 | 3 | 2.7× |
| 256 | 128 | 13 | 9.8× |
| 65,536 | 32,768 | 201 | 163× |
| 1,000,000 | 500,000 | 785 | 637× |

## Common Issues

### Low Success Probability

**Problem**: Target state appears less than 80% of the time.

**Causes**:
- Wrong number of iterations
- Oracle incorrectly marks states
- Too much circuit noise

**Solution**: 
```python
# Verify optimal iterations
import math
n = 3  # qubits
optimal = round(math.pi/4 * math.sqrt(2**n))
print(f"Use {optimal} iterations")
```

### Job Takes Too Long

**Problem**: Job stuck in Running phase.

**Solution**: Check if circuit is too deep:
```bash
kubectl logs qiskit-job-grover-search-101 | grep "depth"
```

For deep circuits, increase resources or use optimization:
```yaml
spec:
  execution:
    optimizationLevel: 3
  resources:
    limits:
      cpu: "8"
      memory: "16Gi"
```

## Scaling to Larger Search Spaces

### 4-Qubit Search (16 items)

```yaml
spec:
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      import math
      
      qc = QuantumCircuit(4, 4)
      qc.h(range(4))
      
      iterations = int(math.pi/4 * math.sqrt(16))  # = 3
      
      # Implement oracle and diffusion for 4 qubits
      # ... (use multi-controlled gates)
```

### Using Circuit from Git

For complex searches, store circuits in Git:

```yaml
spec:
  circuit:
    source: git
    gitRef:
      repository: https://github.com/your-org/quantum-algorithms
      branch: main
      path: grover/search_database.py
```

## Integration with Applications

### REST API for Quantum Search

```python
from flask import Flask, request, jsonify
import subprocess
import yaml

app = Flask(__name__)

@app.route('/quantum-search', methods=['POST'])
def quantum_search():
    target_state = request.json['target']
    n_qubits = len(target_state)
    
    # Generate QiskitJob
    job_spec = {
        'apiVersion': 'quantum.io/v1',
        'kind': 'QiskitJob',
        'metadata': {'name': f'search-{target_state}'},
        'spec': {
            'backend': {'type': 'local_simulator'},
            'circuit': {
                'source': 'inline',
                'code': generate_grover_circuit(target_state)
            }
        }
    }
    
    # Submit to Kubernetes
    subprocess.run(['kubectl', 'apply', '-f', '-'], 
                   input=yaml.dump(job_spec).encode())
    
    return jsonify({'status': 'submitted', 'job': f'search-{target_state}'})

if __name__ == '__main__':
    app.run(port=5000)
```

## Cleanup

```bash
# Delete the job
kubectl delete qiskitjob grover-search-101

# Delete results
kubectl delete configmap grover-search-results
```

## Next Steps

- [Deutsch-Jozsa Algorithm](../examples/circuits/09_deutsch_jozsa.py) - Another query complexity algorithm
- [Bernstein-Vazirani Algorithm](../examples/circuits/08_bernstein_vazirani.py) - Find hidden bit strings
- [Quantum Fourier Transform](../examples/circuits/03_quantum_fourier_transform.py) - Used in Shor's algorithm

## Summary

In this tutorial, you learned:

✅ The theory behind Grover's search algorithm  
✅ How to implement the oracle and diffusion operators  
✅ Calculating optimal iteration counts  
✅ Running Grover's algorithm on QiskitOperator  
✅ Analyzing and visualizing results  
✅ Scaling to larger search spaces  
✅ Running on real quantum hardware  

Congratulations! You've implemented a quantum algorithm with quadratic speedup! 🚀

## Additional Resources

- [Qiskit Textbook: Grover's Algorithm](https://qiskit.org/textbook/ch-algorithms/grover.html)
- [Original Paper (1996)](https://arxiv.org/abs/quant-ph/9605043)
- [Grover's Algorithm Visualization](https://algassert.com/quirk#circuit={%22cols%22:[[%22H%22,%22H%22],[%22X%22,%22X%22],%22%E2%80%A6%22]})
- [QiskitJob API Reference](../reference/qiskitjob.md)

