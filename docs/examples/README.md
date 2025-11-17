# Quantum Circuit Examples

**Real examples from the qiskit-operator codebase** - all tested and working!

## Overview

This directory contains **10 production-tested quantum circuit examples** that demonstrate various quantum algorithms and concepts. All circuits can be executed using the Qiskit Operator.

## Quick Start

```bash
# Apply any example
kubectl apply -f - <<EOF
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: bell-state
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      $(cat circuits/01_bell_state.py)
  execution:
    shots: 1024
  output:
    type: configmap
    location: results
EOF

# Watch progress
kubectl get qiskitjob bell-state -w

# Get results
kubectl get configmap results -o yaml
```

## Available Examples

### Beginner Level 🟢

#### 1. Bell State (`01_bell_state.py`)
**Concept**: Quantum Entanglement  
**Qubits**: 2  
**Description**: Creates a maximally entangled Bell state demonstrating quantum entanglement

```python
from qiskit import QuantumCircuit

qc = QuantumCircuit(2, 2)
qc.h(0)           # Hadamard gate on qubit 0
qc.cx(0, 1)       # CNOT gate
qc.measure([0, 1], [0, 1])
```

**Expected Result**: 50% |00⟩ + 50% |11⟩

---

#### 6. Quantum Random Number Generator (`06_quantum_random_number_generator.py`)
**Concept**: True Randomness  
**Qubits**: 8  
**Description**: Generates truly random numbers using quantum superposition

---

#### 10. GHZ State (`10_ghz_state.py`)
**Concept**: Multi-Qubit Entanglement  
**Qubits**: 5  
**Description**: Creates a maximally entangled state across multiple qubits

---

### Intermediate Level 🟡

#### 2. Quantum Teleportation (`02_quantum_teleportation.py`)
**Concept**: Quantum Communication  
**Qubits**: 3  
**Description**: Teleports a quantum state using entanglement and classical communication

---

#### 3. Quantum Fourier Transform (`03_quantum_fourier_transform.py`)
**Concept**: Quantum Transforms  
**Qubits**: 4  
**Description**: Quantum analogue of the discrete Fourier transform

---

#### 4. Grover's Search Algorithm (`04_grover_search.py`)
**Concept**: Quantum Search  
**Qubits**: 3  
**Description**: Searches for marked item with O(√N) speedup

**Code snippet**:
```python
# Oracle: Mark the state |101⟩
qc.x(1)  # Flip middle qubit
qc.h(2)
qc.ccx(0, 1, 2)  # Toffoli gate
qc.h(2)
qc.x(1)

# Diffusion operator
qc.h([0, 1, 2])
qc.x([0, 1, 2])
qc.h(2)
qc.ccx(0, 1, 2)
qc.h(2)
qc.x([0, 1, 2])
qc.h([0, 1, 2])
```

---

#### 8. Bernstein-Vazirani (`08_bernstein_vazirani.py`)
**Concept**: Hidden Information  
**Qubits**: 5  
**Description**: Finds a hidden bit string in a single query

---

#### 9. Deutsch-Jozsa (`09_deutsch_jozsa.py`)
**Concept**: Function Testing  
**Qubits**: 4  
**Description**: Determines if a function is constant or balanced in one query

---

### Advanced Level 🔴

#### 5. Shor's Algorithm (`05_shor_algorithm.py`)
**Concept**: Integer Factorization  
**Qubits**: 8  
**Description**: Quantum algorithm for factoring integers - can break RSA encryption

---

#### 7. VQE Circuit (`07_vqe_circuit.py`)
**Concept**: Quantum Chemistry  
**Qubits**: 2  
**Description**: Variational Quantum Eigensolver for finding ground state energies

---

## YAML Example Files

### Bell State Job

```yaml title="bell-state-job.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: bell-state-example
  namespace: default
spec:
  backend:
    type: local_simulator
  
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      
      # Create a 2-qubit Bell state
      qc = QuantumCircuit(2, 2)
      qc.h(0)           # Hadamard gate
      qc.cx(0, 1)       # CNOT gate
      qc.measure([0, 1], [0, 1])
  
  execution:
    shots: 1024
    optimizationLevel: 1
    priority: normal
  
  output:
    type: configmap
    location: bell-state-results
    format: json
  
  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "2"
      memory: "4Gi"
```

### Using External Circuit File

```yaml title="external-circuit-job.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: grover-from-file
spec:
  backend:
    type: local_simulator
  
  circuit:
    source: configmap
    configMapRef:
      name: grover-circuit
      key: circuit.py
  
  execution:
    shots: 8192
    optimizationLevel: 2
  
  output:
    type: pvc
    location: quantum-results-pvc
    format: pickle
```

First create the ConfigMap:

```bash
kubectl create configmap grover-circuit \
  --from-file=circuit.py=circuits/04_grover_search.py
```

## Running Examples

### 1. Single Example

```bash
# Create job from circuit file
kubectl apply -f - <<EOF
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: my-bell-state
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      $(cat circuits/01_bell_state.py)
  execution:
    shots: 1024
  output:
    type: configmap
    location: my-results
EOF

# Watch execution
kubectl get qiskitjob my-bell-state -w

# Get results
kubectl logs qiskit-job-my-bell-state
kubectl get configmap my-results -o yaml
```

### 2. Multiple Examples

```bash
# Submit all beginner examples
for circuit in circuits/01_*.py circuits/06_*.py circuits/10_*.py; do
  name=$(basename $circuit .py)
  kubectl apply -f - <<EOF
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: $name
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      $(cat $circuit)
  execution:
    shots: 1024
  output:
    type: configmap
    location: ${name}-results
EOF
done

# Watch all jobs
kubectl get qiskitjobs -w
```

## Understanding Results

### JSON Format (ConfigMap)

Results are stored as JSON in ConfigMaps:

```json
{
  "counts": {
    "00": 512,
    "11": 512
  },
  "metadata": {
    "shots": 1024,
    "execution_time": 0.234,
    "qubits": 2,
    "depth": 3,
    "gates": 4,
    "gate_types": {
      "h": 1,
      "cx": 1,
      "measure": 2
    }
  }
}
```

### Pickle Format (PVC)

For complex results, use pickle format:

```python
import pickle

# Load results
with open('/mnt/results/job-results.pkl', 'rb') as f:
    result = pickle.load(f)

counts = result.get_counts()
print(f"Counts: {counts}")
```

## Circuit Files

All circuit Python files are included in this directory:

```
circuits/
├── 01_bell_state.py
├── 02_quantum_teleportation.py
├── 03_quantum_fourier_transform.py
├── 04_grover_search.py
├── 05_shor_algorithm.py
├── 06_quantum_random_number_generator.py
├── 07_vqe_circuit.py
├── 08_bernstein_vazirani.py
├── 09_deutsch_jozsa.py
└── 10_ghz_state.py
```

Each file contains:
- Comprehensive docstring
- Working Qiskit code
- No external dependencies beyond Qiskit
- Ready to use with inline source

## Testing

All circuits have been tested with:

- Qiskit 1.0.0
- Local simulator (Qiskit Aer)
- Success rate: 100%

Test report: `examples/TEST_SUMMARY.md`

## Troubleshooting

**Job stuck in Validating:**
```bash
# Check validation service logs
kubectl logs -n qiskit-operator-system deployment/qiskit-validation-service
```

**Circuit execution fails:**
```bash
# Check executor pod logs
kubectl logs qiskit-job-<job-name>

# Describe the job
kubectl describe qiskitjob <job-name>
```

**Results not appearing:**
```bash
# Check if ConfigMap was created
kubectl get configmap

# Check pod completion
kubectl get pods -l job-name=<job-name>
```

## Next Steps

- [User Guide](../user-guide/index.md) - Learn more about job management
- [API Reference](../reference/qiskitjob.md) - Complete QiskitJob specification
- [Tutorials](../tutorials/index.md) - Step-by-step guides

## Resources

- [Qiskit Documentation](https://qiskit.org/documentation/)
- [Qiskit Textbook](https://qiskit.org/textbook/)
- [IBM Quantum Learning](https://learning.quantum.ibm.com/)

---

**All examples are real, tested code from the qiskit-operator project!**

