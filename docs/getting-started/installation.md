# Installation Guide

This guide covers different methods to install Qiskit Operator on your Kubernetes cluster.

## Prerequisites

Before installing, ensure you have:

- Kubernetes cluster (1.24+)
- `kubectl` configured and connected to your cluster
- Appropriate permissions to create namespaces, CRDs, and deployments

## Installation Methods

Choose the installation method that best fits your needs:

=== "Helm (Recommended)"

    ### Helm Installation

    Helm is the recommended installation method for production deployments.

    #### Step 1: Add Helm Repository

    ```bash
    helm repo add qiskit-operator https://quantum-operator.github.io/qiskit-operator
    helm repo update
    ```

    #### Step 2: Install the Operator

    ```bash
    helm install qiskit-operator qiskit-operator/qiskit-operator \
      --namespace qiskit-operator-system \
      --create-namespace
    ```

    #### Step 3: Verify Installation

    ```bash
    # Check operator pods
    kubectl get pods -n qiskit-operator-system

    # Check CRDs
    kubectl get crds | grep quantum.io
    ```

    Expected output:
    ```
    NAME                                        READY   STATUS    AGE
    qiskit-operator-controller-manager-xxx      2/2     Running   1m
    qiskit-validation-service-xxx               1/1     Running   1m

    qiskitbackends.quantum.io
    qiskitbudgets.quantum.io
    qiskitjobs.quantum.io
    qiskitsessions.quantum.io
    ```

    #### Configuration Options

    Customize your installation:

    ```bash
    helm install qiskit-operator qiskit-operator/qiskit-operator \
      --namespace qiskit-operator-system \
      --create-namespace \
      --set controller.replicas=2 \
      --set validation.replicas=3 \
      --set metrics.enabled=true \
      --set rbac.create=true
    ```

    #### Values File

    Create a `values.yaml` file for complex configurations:

    ```yaml title="values.yaml"
    controller:
      replicas: 2
      image:
        repository: sudeshmu/qiskit-operator
        tag: controller-latest
      resources:
        limits:
          cpu: 500m
          memory: 512Mi
        requests:
          cpu: 100m
          memory: 128Mi

    validation:
      replicas: 3
      image:
        repository: sudeshmu/qiskit-operator
        tag: validation-latest
      resources:
        limits:
          cpu: 2000m
          memory: 2Gi
        requests:
          cpu: 500m
          memory: 1Gi

    metrics:
      enabled: true
      serviceMonitor:
        enabled: true

    rbac:
      create: true

    networkPolicy:
      enabled: true
    ```

    Install with custom values:

    ```bash
    helm install qiskit-operator qiskit-operator/qiskit-operator \
      -f values.yaml \
      --namespace qiskit-operator-system \
      --create-namespace
    ```

=== "kubectl"

    ### kubectl Installation

    Direct installation using kubectl and manifest files.

    #### Step 1: Install CRDs

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/crd/bases/quantum_v1_qiskitjob.yaml
    kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/crd/bases/quantum_v1_qiskitbackend.yaml
    kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/crd/bases/quantum_v1_qiskitsession.yaml
    kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/crd/bases/quantum_v1_qiskitbudget.yaml
    ```

    #### Step 2: Create Namespace

    ```bash
    kubectl create namespace qiskit-operator-system
    ```

    #### Step 3: Install RBAC

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/rbac/
    ```

    #### Step 4: Deploy Controller

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/manager/manager.yaml
    ```

    #### Step 5: Deploy Validation Service

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/validation/validation.yaml
    ```

    #### Step 6: Verify Installation

    ```bash
    kubectl get pods -n qiskit-operator-system
    kubectl get crds | grep quantum.io
    ```

=== "From Source"

    ### Build from Source

    For development or customization.

    #### Step 1: Clone Repository

    ```bash
    git clone https://github.com/quantum-operator/qiskit-operator.git
    cd qiskit-operator
    ```

    #### Step 2: Install CRDs

    ```bash
    make install
    ```

    #### Step 3: Build Controller Image

    ```bash
    make docker-build IMG=your-registry/qiskit-operator:v1
    make docker-push IMG=your-registry/qiskit-operator:v1
    ```

    #### Step 4: Build Validation Service

    ```bash
    cd validation-service
    docker build -t your-registry/qiskit-validation:v1 .
    docker push your-registry/qiskit-validation:v1
    cd ..
    ```

    #### Step 5: Deploy

    ```bash
    make deploy IMG=your-registry/qiskit-operator:v1
    ```

    #### Step 6: Verify

    ```bash
    kubectl get pods -n qiskit-operator-system
    ```

=== "Local Development"

    ### Local Development with Kind

    Perfect for testing and development.

    #### Step 1: Install Kind

    ```bash
    # macOS
    brew install kind

    # Linux
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    ```

    #### Step 2: Create Kind Cluster

    ```bash
    kind create cluster --name qiskit-dev --config - <<EOF
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
      extraPortMappings:
      - containerPort: 30080
        hostPort: 8080
        protocol: TCP
    EOF
    ```

    #### Step 3: Clone and Build

    ```bash
    git clone https://github.com/quantum-operator/qiskit-operator.git
    cd qiskit-operator

    # Build executor image
    cd execution-pods
    docker build -t qiskit-executor:dev .
    kind load docker-image qiskit-executor:dev --name qiskit-dev
    cd ..
    ```

    #### Step 4: Install CRDs

    ```bash
    make install
    ```

    #### Step 5: Run Operator Locally

    ```bash
    make run
    ```

    This runs the operator on your local machine, connected to the Kind cluster.

## Docker Images

### Controller Image

```bash
docker pull sudeshmu/qiskit-operator:controller-latest
```

**Platforms**: linux/amd64, linux/arm64  
**Size**: ~20 MB  
**Base**: Distroless

### Validation Service Image

```bash
docker pull sudeshmu/qiskit-operator:validation-latest
```

**Platforms**: linux/amd64, linux/arm64  
**Size**: ~1.3 GB  
**Base**: Python 3.11 Slim

### Executor Image

```bash
docker pull sudeshmu/qiskit-operator:executor-latest
```

**Platforms**: linux/amd64, linux/arm64  
**Size**: ~1.5 GB  
**Base**: Python 3.11 Slim

## Verification

### Check Installation

```bash
# Verify all components are running
kubectl get pods -n qiskit-operator-system

# Check CRDs
kubectl get crds | grep quantum.io

# Check operator version
kubectl get deployment -n qiskit-operator-system qiskit-operator-controller -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### Test with Sample Job

```bash
# Apply sample job
kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/samples/example-local-simulator.yaml

# Watch job progress
kubectl get qiskitjob bell-state-example -w

# Check results
kubectl get configmap bell-state-results -o yaml
```

## Post-Installation

### Set Up IBM Quantum Credentials

If you plan to use IBM Quantum hardware:

```bash
kubectl create secret generic ibm-quantum-credentials \
  --from-literal=api-key=YOUR_IBM_QUANTUM_API_KEY \
  --namespace default
```

### Install Monitoring (Optional)

```bash
# Install Prometheus
kubectl apply -f config/prometheus/

# Access Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000
# Visit http://localhost:3000 (admin/admin)
```

### Configure Default Backend

Create a default backend configuration:

```yaml
apiVersion: quantum.io/v1
kind: QiskitBackend
metadata:
  name: default-simulator
  namespace: default
spec:
  type: local_simulator
  default: true
```

## Upgrade

### Helm Upgrade

```bash
# Update repository
helm repo update

# Upgrade operator
helm upgrade qiskit-operator qiskit-operator/qiskit-operator \
  --namespace qiskit-operator-system
```

### kubectl Upgrade

```bash
# Update CRDs
kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/crd/bases/

# Update deployment
kubectl apply -f https://raw.githubusercontent.com/quantum-operator/qiskit-operator/main/config/manager/manager.yaml
```

## Uninstallation

### Helm Uninstall

```bash
helm uninstall qiskit-operator --namespace qiskit-operator-system
kubectl delete namespace qiskit-operator-system
kubectl delete crds -l app.kubernetes.io/name=qiskit-operator
```

### kubectl Uninstall

```bash
# Delete deployment
kubectl delete -f config/manager/

# Delete CRDs (this will delete all QiskitJobs!)
kubectl delete crds qiskitjobs.quantum.io
kubectl delete crds qiskitbackends.quantum.io
kubectl delete crds qiskitsessions.quantum.io
kubectl delete crds qiskitbudgets.quantum.io

# Delete namespace
kubectl delete namespace qiskit-operator-system
```

## Troubleshooting

### Operator Not Starting

```bash
# Check operator logs
kubectl logs -n qiskit-operator-system deployment/qiskit-operator-controller -f

# Check events
kubectl get events -n qiskit-operator-system --sort-by='.lastTimestamp'
```

### CRD Issues

```bash
# List CRDs
kubectl get crds | grep quantum.io

# Describe CRD
kubectl describe crd qiskitjobs.quantum.io

# Reinstall CRDs
make uninstall
make install
```

### Image Pull Issues

```bash
# Check image pull secrets
kubectl get secrets -n qiskit-operator-system

# Manually pull image to verify
docker pull sudeshmu/qiskit-operator:controller-latest
```

### Permission Issues

```bash
# Check service account
kubectl get sa -n qiskit-operator-system

# Check role bindings
kubectl get rolebindings,clusterrolebindings | grep qiskit
```

## Next Steps

- [Submit Your First Job](first-job.md)
- [Configure Backends](../backends/index.md)
- [Set Up Monitoring](../user-guide/monitoring.md)
- [Production Deployment](../deployment/production.md)

## Additional Resources

- [Helm Chart Repository](https://github.com/quantum-operator/qiskit-operator-helm)
- [Docker Hub](https://hub.docker.com/r/sudeshmu/qiskit-operator)
- [GitHub Releases](https://github.com/quantum-operator/qiskit-operator/releases)

