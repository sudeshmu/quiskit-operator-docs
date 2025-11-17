# Example Quantum Circuits

A comprehensive collection of quantum circuit examples to get you started with Qiskit Operator.

## Beginner Examples

### 1. Bell State (Quantum Entanglement)

Create the simplest entangled quantum state.

```yaml title="bell-state.yaml"
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
      from qiskit import QuantumCircuit
      
      # Create Bell state |Φ+⟩ = (|00⟩ + |11⟩)/√2
      qc = QuantumCircuit(2, 2)
      qc.h(0)           # Hadamard on qubit 0
      qc.cx(0, 1)       # CNOT with control=0, target=1
      qc.measure([0, 1], [0, 1])
  execution:
    shots: 1024
  output:
    type: configmap
    location: bell-state-results
```

**Expected Result**: 50% |00⟩ + 50% |11⟩

**Apply:**
```bash
kubectl apply -f bell-state.yaml
kubectl get qiskitjob bell-state -w
```

---

### 2. GHZ State (3-Qubit Entanglement)

Create a maximally entangled state with three qubits.

```yaml title="ghz-state.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: ghz-state
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      
      # GHZ state: (|000⟩ + |111⟩)/√2
      qc = QuantumCircuit(3, 3)
      qc.h(0)
      qc.cx(0, 1)
      qc.cx(0, 2)
      qc.measure([0, 1, 2], [0, 1, 2])
  execution:
    shots: 2048
  output:
    type: configmap
    location: ghz-results
```

**Expected Result**: 50% |000⟩ + 50% |111⟩

---

### 3. Quantum Random Number Generator

Generate truly random numbers using quantum mechanics.

```yaml title="qrng.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: quantum-rng
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      
      # 8-bit random number generator
      qc = QuantumCircuit(8, 8)
      qc.h(range(8))  # Put all qubits in superposition
      qc.measure(range(8), range(8))
  execution:
    shots: 100  # Generate 100 random numbers
  output:
    type: configmap
    location: random-numbers
```

**Use Case**: Cryptographic keys, Monte Carlo simulations

---

## Intermediate Examples

### 4. Quantum Teleportation

Teleport a quantum state using entanglement.

```yaml title="teleportation.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: quantum-teleportation
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      import numpy as np
      
      # Prepare state to teleport: |ψ⟩ = cos(θ)|0⟩ + sin(θ)|1⟩
      qc = QuantumCircuit(3, 3)
      theta = np.pi / 4
      
      # Initialize qubit 0 with the state to teleport
      qc.ry(2 * theta, 0)
      qc.barrier()
      
      # Create entangled pair (qubits 1 and 2)
      qc.h(1)
      qc.cx(1, 2)
      qc.barrier()
      
      # Bell measurement on qubits 0 and 1
      qc.cx(0, 1)
      qc.h(0)
      qc.barrier()
      
      # Measure qubits 0 and 1
      qc.measure([0, 1], [0, 1])
      qc.barrier()
      
      # Conditional corrections on qubit 2
      qc.x(2).c_if(1, 1)
      qc.z(2).c_if(0, 1)
      
      # Measure final state
      qc.measure(2, 2)
  execution:
    shots: 4096
  output:
    type: configmap
    location: teleportation-results
```

---

### 5. Grover's Search Algorithm

Quantum search with quadratic speedup.

```yaml title="grover.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: grover-search
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      
      # Search for |11⟩ in 2-qubit space
      qc = QuantumCircuit(2, 2)
      
      # Initialize: superposition
      qc.h([0, 1])
      
      # Oracle: mark |11⟩
      qc.cz(0, 1)
      
      # Diffusion operator
      qc.h([0, 1])
      qc.z([0, 1])
      qc.cz(0, 1)
      qc.h([0, 1])
      
      qc.measure([0, 1], [0, 1])
  execution:
    shots: 8192
    optimizationLevel: 2
  output:
    type: configmap
    location: grover-results
```

**Expected Result**: ~95% |11⟩ (the marked state)

---

### 6. Quantum Fourier Transform

Implement the quantum analogue of FFT.

```yaml title="qft.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: qft-circuit
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      import numpy as np
      
      def qft(n):
          qc = QuantumCircuit(n, n)
          for j in range(n):
              qc.h(j)
              for k in range(j+1, n):
                  qc.cp(np.pi/2**(k-j), k, j)
          # Swap qubits
          for j in range(n//2):
              qc.swap(j, n-j-1)
          return qc
      
      qc = qft(4)
      qc.measure_all()
  execution:
    shots: 1024
    optimizationLevel: 3
  output:
    type: configmap
    location: qft-results
```

**Use Case**: Key component in Shor's algorithm and phase estimation

---

### 7. Deutsch-Jozsa Algorithm

Determine if a function is constant or balanced in one query.

```yaml title="deutsch-jozsa.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: deutsch-jozsa
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      
      # Test if function is constant or balanced
      n = 3  # number of qubits
      qc = QuantumCircuit(n+1, n)
      
      # Initialize
      qc.x(n)  # Flip ancilla qubit
      qc.h(range(n+1))  # Apply Hadamard to all
      qc.barrier()
      
      # Oracle for balanced function (example: f(x) = x₀ ⊕ x₁)
      qc.cx(0, n)
      qc.cx(1, n)
      qc.barrier()
      
      # Apply Hadamard to input qubits
      qc.h(range(n))
      qc.barrier()
      
      # Measure input qubits
      qc.measure(range(n), range(n))
  execution:
    shots: 1024
  output:
    type: configmap
    location: deutsch-jozsa-results
```

**Result Interpretation**:
- All zeros → Constant function
- Non-zero → Balanced function

---

### 8. Bernstein-Vazirani Algorithm

Find a hidden bit string in one query.

```yaml title="bernstein-vazirani.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: bernstein-vazirani
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      
      # Find hidden string s where f(x) = s·x
      n = 4
      s = '1011'  # Hidden string
      
      qc = QuantumCircuit(n+1, n)
      
      # Initialize
      qc.x(n)
      qc.h(range(n+1))
      qc.barrier()
      
      # Oracle: implement f(x) = s·x
      for i in range(n):
          if s[i] == '1':
              qc.cx(i, n)
      qc.barrier()
      
      # Apply Hadamard and measure
      qc.h(range(n))
      qc.measure(range(n), range(n))
  execution:
    shots: 1024
  output:
    type: configmap
    location: bernstein-vazirani-results
```

**Expected Result**: The hidden string '1011' with high probability

---

## Advanced Examples

### 9. Variational Quantum Eigensolver (VQE)

Find ground state energy of a molecular Hamiltonian.

```yaml title="vqe.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: vqe-h2-molecule
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      import numpy as np
      
      # VQE ansatz for H2 molecule
      def vqe_circuit(params):
          qc = QuantumCircuit(2, 2)
          
          # Variational ansatz (UCC-like)
          qc.ry(params[0], 0)
          qc.ry(params[1], 1)
          qc.cx(0, 1)
          qc.ry(params[2], 0)
          qc.ry(params[3], 1)
          
          qc.measure_all()
          return qc
      
      # Example parameters (would be optimized classically)
      params = [0.5, 0.3, 0.2, 0.4]
      qc = vqe_circuit(params)
  execution:
    shots: 8192
    optimizationLevel: 3
  budget:
    maxCost: "$10.00"
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  output:
    type: s3
    location: s3://quantum-results/vqe/h2-molecule
    format: json
```

**Use Case**: Quantum chemistry, drug discovery, materials science

---

### 10. Shor's Algorithm (Simplified)

Factor integers using quantum period finding.

```yaml title="shor.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: shor-factoring
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      import numpy as np
      
      # Simplified Shor's algorithm for factoring 15
      def shor_circuit(a=7, N=15):
          n_count = 4  # Number of counting qubits
          qc = QuantumCircuit(n_count + 4, n_count)
          
          # Initialize counting qubits in superposition
          for q in range(n_count):
              qc.h(q)
          
          # Initialize auxiliary register to |1⟩
          qc.x(n_count)
          
          # Controlled-U operations (simplified)
          repetitions = 1
          for counting_qubit in range(n_count):
              for i in range(repetitions):
                  # Modular exponentiation (simplified)
                  qc.cx(counting_qubit, n_count)
              repetitions *= 2
          
          # Inverse QFT on counting register
          for j in range(n_count//2):
              qc.swap(j, n_count-j-1)
          
          for j in range(n_count):
              for k in range(j):
                  qc.cp(-np.pi/float(2**(j-k)), k, j)
              qc.h(j)
          
          # Measure counting register
          qc.measure(range(n_count), range(n_count))
          
          return qc
      
      qc = shor_circuit()
  execution:
    shots: 8192
    optimizationLevel: 3
  output:
    type: configmap
    location: shor-results
```

**Use Case**: Cryptography, breaking RSA encryption

---

## Cost-Optimized Examples

### Budget-Constrained Job

```yaml title="cost-optimized.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: cost-sensitive-job
spec:
  backend:
    type: ibm_quantum
  
  backendSelection:
    weights:
      cost: 0.80        # Prioritize cost
      queueTime: 0.10
      capability: 0.05
      availability: 0.05
    fallbackToSimulator: true  # Use simulator if too expensive
  
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      qc = QuantumCircuit(3, 3)
      qc.h(range(3))
      qc.measure_all()
  
  execution:
    shots: 1024
  
  budget:
    maxCost: "$5.00"
    costCenter: research-team
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  output:
    type: configmap
    location: cost-optimized-results
```

---

## Session-Based Example

For iterative algorithms like VQE that require multiple circuit executions.

```yaml title="session-vqe.yaml"
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: session-vqe
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
  
  session:
    name: vqe-optimization-session
    maxTime: 3600  # 1 hour
    mode: dedicated  # Lock QPU for exclusive access
  
  circuit:
    source: git
    gitRef:
      repository: https://github.com/your-org/quantum-algorithms
      branch: main
      path: vqe/water_molecule.py
  
  execution:
    shots: 4096
    optimizationLevel: 3
  
  budget:
    maxCost: "$100.00"
    costCenter: chemistry-research
    project: water-simulation
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  output:
    type: pvc
    location: quantum-results-pvc
    format: pickle
```

---

## Running All Examples

### Download All Examples

```bash
# Clone examples repository
git clone https://github.com/quantum-operator/qiskit-operator-examples
cd qiskit-operator-examples

# Or download individual files
wget https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/samples/example-local-simulator.yaml
```

### Run Examples

```bash
# Run a single example
kubectl apply -f bell-state.yaml

# Run all beginner examples
kubectl apply -f beginner/

# Run all examples
kubectl apply -f .
```

### Monitor Progress

```bash
# Watch all jobs
kubectl get qiskitjobs -w

# Get job status
kubectl describe qiskitjob bell-state

# View results
kubectl get configmap bell-state-results -o yaml
```

### Clean Up

```bash
# Delete a single job
kubectl delete qiskitjob bell-state

# Delete all jobs
kubectl delete qiskitjobs --all

# Delete results
kubectl delete configmaps -l app=qiskit-operator
```

## GitHub Examples Repository

All examples are available on GitHub:

**Repository**: [github.com/quantum-operator/qiskit-operator-examples](https://github.com/quantum-operator/qiskit-operator-examples)

```bash
git clone https://github.com/quantum-operator/qiskit-operator-examples
cd qiskit-operator-examples
ls -la
```

## Next Steps

- [Tutorials](../tutorials/index.md) - Step-by-step guides
- [API Reference](qiskitjob.md) - Complete QiskitJob specification
- [Backends](../backends/index.md) - Backend configuration
- [User Guide](../user-guide/index.md) - Comprehensive documentation

