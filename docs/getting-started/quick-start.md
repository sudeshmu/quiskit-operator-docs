# Quick Start Guide

Get your first quantum circuit running on Kubernetes in under 10 minutes!

## Prerequisites

Before you begin, ensure you have:

- ✅ Kubernetes cluster (v1.24+)
  - Kind, Minikube, or cloud cluster (EKS, GKE, AKS)
- ✅ `kubectl` installed and configured
- ✅ Docker or Podman installed
- ✅ (Optional) IBM Quantum account for real quantum hardware

## Step 1: Install QiskitOperator

### Option A: Using kubectl (Recommended)

```bash
# Install CRDs and operator
kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/install.yaml

# Verify installation
kubectl get pods -n qiskit-operator-system
```

Expected output:
```
NAME                                        READY   STATUS    RESTARTS   AGE
qiskit-operator-controller-xxxxx            1/1     Running   0          30s
validation-service-xxxxx                    1/1     Running   0          30s
```

### Option B: Using Helm

```bash
# Add Helm repository
helm repo add qiskit-operator https://quantum-operator.github.io/qiskit-operator
helm repo update

# Install
helm install qiskit-operator qiskit-operator/qiskit-operator \
  --namespace qiskit-operator-system \
  --create-namespace

# Verify
helm status qiskit-operator -n qiskit-operator-system
```

### Option C: For Local Development (Kind)

Perfect for testing and development:

```bash
# Create Kind cluster
kind create cluster --name qiskit-dev

# Build and load executor image
cd qiskit-operator/execution-pods
docker build -t qiskit-executor:v1 .
kind load docker-image qiskit-executor:v1 --name qiskit-dev

# Install CRDs
cd ..
make install

# Run operator locally (keep this terminal open)
make run
```

## Step 2: Verify Installation

Check that CRDs are installed:

```bash
kubectl get crds | grep quantum.io
```

Expected output:
```
qiskitbackends.quantum.io
qiskitbudgets.quantum.io
qiskitjobs.quantum.io
qiskitsessions.quantum.io
```

## Step 3: Run Your First Quantum Circuit

Create a file named `hello-quantum.yaml`:

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: hello-quantum
  namespace: default
spec:
  # Use local simulator (no quantum hardware needed)
  backend:
    type: local_simulator
  
  # Define a simple Bell state circuit
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      
      # Create a Bell state (entangled qubits)
      qc = QuantumCircuit(2, 2)
      qc.h(0)        # Hadamard gate on qubit 0
      qc.cx(0, 1)    # CNOT gate
      qc.measure([0, 1], [0, 1])  # Measure both qubits
  
  # Execution parameters
  execution:
    shots: 1024              # Run circuit 1024 times
    optimizationLevel: 1     # Optimize circuit
  
  # Store results in a ConfigMap
  output:
    type: configmap
    location: hello-quantum-results
    format: json
```

Apply the job:

```bash
kubectl apply -f hello-quantum.yaml
```

## Step 4: Monitor Execution

Watch the job progress:

```bash
kubectl get qiskitjob hello-quantum -w
```

You'll see the job transition through phases:

```
NAME             PHASE        BACKEND           COST     AGE
hello-quantum    Pending      local_simulator   $0.00    1s
hello-quantum    Validating   local_simulator   $0.00    2s
hello-quantum    Scheduling   local_simulator   $0.00    3s
hello-quantum    Running      local_simulator   $0.00    5s
hello-quantum    Completed    local_simulator   $0.00    28s
```

Press `Ctrl+C` when phase is `Completed`.

## Step 5: View Results

Get the results from the ConfigMap:

```bash
kubectl get configmap hello-quantum-results -o yaml
```

Or extract just the results:

```bash
kubectl get configmap hello-quantum-results -o jsonpath='{.data.results}' | jq
```

Expected output:

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
    "gates": 4,
    "execution_time": 1.23
  },
  "backend": "local_simulator",
  "success": true
}
```

🎉 **Congratulations!** You've just created quantum entanglement on Kubernetes!

The 50/50 split between `00` and `11` confirms you created a Bell state - the qubits are perfectly entangled.

## Step 6: View Execution Logs

Check detailed execution logs:

```bash
# Find the pod
kubectl get pods -l job-name=hello-quantum

# View logs
kubectl logs qiskit-job-hello-quantum
```

Sample output:

```
[INFO] 2025-11-18 10:30:45 - Starting quantum circuit execution
[INFO] 2025-11-18 10:30:45 - Validating circuit...
[INFO] 2025-11-18 10:30:46 - Circuit validation: PASSED
[INFO] 2025-11-18 10:30:46 - Circuit metrics:
[INFO] 2025-11-18 10:30:46 -   Qubits: 2
[INFO] 2025-11-18 10:30:46 -   Depth: 3
[INFO] 2025-11-18 10:30:46 -   Gates: 4
[INFO] 2025-11-18 10:30:46 - Backend: local_simulator
[INFO] 2025-11-18 10:30:46 - Executing circuit with 1024 shots...
[INFO] 2025-11-18 10:30:47 - Execution completed in 1.23s
[INFO] 2025-11-18 10:30:47 - Results: {'00': 512, '11': 512}
[INFO] 2025-11-18 10:30:47 - Storing results in ConfigMap: hello-quantum-results
[INFO] 2025-11-18 10:30:47 - Job completed successfully
```

## What's Next?

### Try More Examples

#### Grover's Search Algorithm

```bash
kubectl apply -f - <<EOF
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
      import math
      
      qc = QuantumCircuit(3, 3)
      qc.h([0, 1, 2])
      
      # Grover iteration
      optimal_iterations = int(math.pi/4 * math.sqrt(8))
      for _ in range(optimal_iterations):
          # Oracle for |101⟩
          qc.x(1)
          qc.h(2)
          qc.ccx(0, 1, 2)
          qc.h(2)
          qc.x(1)
          qc.barrier()
          
          # Diffusion
          qc.h([0, 1, 2])
          qc.x([0, 1, 2])
          qc.h(2)
          qc.ccx(0, 1, 2)
          qc.h(2)
          qc.x([0, 1, 2])
          qc.h([0, 1, 2])
          qc.barrier()
      
      qc.measure([0, 1, 2], [0, 1, 2])
  execution:
    shots: 2048
  output:
    type: configmap
    location: grover-results
EOF
```

#### Quantum Random Number Generator

```bash
kubectl apply -f - <<EOF
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: qrng
spec:
  backend:
    type: local_simulator
  circuit:
    source: inline
    code: |
      from qiskit import QuantumCircuit
      
      # 8-qubit quantum RNG
      qc = QuantumCircuit(8, 8)
      qc.h(range(8))
      qc.measure(range(8), range(8))
  execution:
    shots: 100
  output:
    type: configmap
    location: qrng-results
EOF
```

### Use Real Quantum Hardware

#### 1. Get IBM Quantum API Key

Visit [IBM Quantum](https://quantum.ibm.com/) and create an account to get your API key.

#### 2. Create Kubernetes Secret

```bash
kubectl create secret generic ibm-quantum-credentials \
  --from-literal=api-key=YOUR_IBM_QUANTUM_API_KEY
```

#### 3. Submit Job to Real Quantum Computer

```bash
kubectl apply -f - <<EOF
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: real-quantum-hardware
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane  # 127-qubit quantum processor
  
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
    optimizationLevel: 3  # Maximum optimization for real hardware
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  budget:
    maxCost: "$2.00"  # Set a budget limit
  
  output:
    type: configmap
    location: real-quantum-results
EOF
```

**Note:** Real quantum hardware may take longer due to queue times and will have noise affecting results.

### Explore All Features

Create a comprehensive production job:

```yaml
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: production-job
  labels:
    team: quantum-research
    environment: production
spec:
  backend:
    type: ibm_quantum
    name: ibm_brisbane
  
  circuit:
    source: git
    gitRef:
      repository: https://github.com/your-org/quantum-algorithms
      branch: main
      path: production/algorithm.py
  
  execution:
    shots: 8192
    optimizationLevel: 3
    priority: high
  
  session:
    name: vqe-session
    maxTime: 3600
    mode: dedicated
  
  budget:
    maxCost: "$50.00"
    costCenter: "research-dept"
  
  backendSelection:
    weights:
      cost: 0.40
      queueTime: 0.30
      capability: 0.20
      availability: 0.10
    fallbackToSimulator: true
  
  output:
    type: s3
    location: s3://quantum-results/production/
    format: json
  
  resources:
    requests:
      cpu: "2"
      memory: "8Gi"
    limits:
      cpu: "8"
      memory: "32Gi"
  
  credentials:
    secretRef:
      name: ibm-quantum-credentials
  
  retryPolicy:
    maxRetries: 3
```

## Common Commands

### Manage Jobs

```bash
# List all quantum jobs
kubectl get qiskitjobs

# Get job details
kubectl describe qiskitjob hello-quantum

# Delete a job
kubectl delete qiskitjob hello-quantum

# Delete all jobs
kubectl delete qiskitjobs --all
```

### View Results

```bash
# List result ConfigMaps
kubectl get configmaps -l app=qiskit-operator

# View results
kubectl get configmap hello-quantum-results -o yaml

# Extract and format
kubectl get configmap hello-quantum-results -o jsonpath='{.data.results}' | jq
```

### Debugging

```bash
# Check operator logs
kubectl logs -n qiskit-operator-system deployment/qiskit-operator-controller

# Check validation service
kubectl logs -n qiskit-operator-system deployment/validation-service

# Check executor pod
kubectl logs qiskit-job-hello-quantum

# Get job status
kubectl get qiskitjob hello-quantum -o jsonpath='{.status.phase}'
```

## Cleanup

When you're done:

```bash
# Delete the job
kubectl delete qiskitjob hello-quantum

# Delete the results
kubectl delete configmap hello-quantum-results

# Uninstall operator (optional)
kubectl delete -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/install.yaml

# Delete Kind cluster (if using Kind)
kind delete cluster --name qiskit-dev
```

## Troubleshooting

### Job Stuck in Pending

**Problem:** Job doesn't progress past Pending phase.

**Solution:**
```bash
# Check if operator is running
kubectl get pods -n qiskit-operator-system

# Check operator logs
kubectl logs -n qiskit-operator-system deployment/qiskit-operator-controller

# Ensure CRDs are installed
kubectl get crds | grep quantum.io
```

### Pod ImagePullBackOff

**Problem:** Executor pod can't pull the image.

**Solution for Kind:**
```bash
# Load the image into Kind
kind load docker-image qiskit-executor:v1 --name qiskit-dev
```

**Solution for private registries:**
```bash
# Create imagePullSecret
kubectl create secret docker-registry regcred \
  --docker-server=your-registry.com \
  --docker-username=username \
  --docker-password=password
```

### Circuit Validation Failed

**Problem:** Job fails with validation error.

**Solution:** Test your circuit locally first:
```python
from qiskit import QuantumCircuit

# Test your circuit code
qc = QuantumCircuit(2, 2)
qc.h(0)
qc.cx(0, 1)
qc.measure([0, 1], [0, 1])

print(qc)  # Should print the circuit
```

## Next Steps

Now that you've successfully run your first quantum job, explore these topics:

1. **[Tutorials](../tutorials/index.md)** - Step-by-step guides for various algorithms
2. **[User Guide](../user-guide/index.md)** - Deep dive into all features
3. **[Examples](../examples/README.md)** - 10+ quantum circuit examples
4. **[API Reference](../reference/index.md)** - Complete CRD specifications
5. **[Production Deployment](../deployment/production.md)** - Deploy to production

## Learning Resources

### Quantum Computing Basics

- [Qiskit Textbook](https://qiskit.org/textbook/)
- [IBM Quantum Learning](https://learning.quantum.ibm.com/)
- [Qiskit YouTube Channel](https://www.youtube.com/c/qiskit)

### QiskitOperator

- [Complete Documentation](../index.md)
- [GitHub Repository](https://github.com/quantum-operator/qiskit-operator)
- [Community Slack](https://quantum-operator.slack.com)

## Success!

🎉 You've successfully:

- ✅ Installed QiskitOperator
- ✅ Created a Bell state (quantum entanglement)
- ✅ Retrieved and interpreted results
- ✅ Learned basic kubectl commands for quantum jobs

Welcome to the cloud-native quantum computing revolution! 🚀

---

**Questions or issues?** 

- 📖 [Full Documentation](../index.md)
- 💬 [GitHub Discussions](https://github.com/quantum-operator/qiskit-operator/discussions)
- 🐛 [Report an Issue](https://github.com/quantum-operator/qiskit-operator/issues)
