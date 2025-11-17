# Tutorials

Learn Qiskit Operator through hands-on tutorials that cover everything from basic concepts to advanced production deployments.

## Learning Path

Follow these tutorials in order for a comprehensive understanding:

```mermaid
graph LR
    A[1. Bell State] --> B[2. Grover's Algorithm]
    B --> C[3. VQE Chemistry]
    C --> D[4. Quantum Teleportation]
    D --> E[5. Cost Optimization]
    E --> F[6. Multi-Backend]
    F --> G[7. CI/CD Integration]
    G --> H[8. Production Deployment]
    
    style A fill:#6d4c7d
    style B fill:#6d4c7d
    style C fill:#6d4c7d
    style D fill:#6d4c7d
    style E fill:#6d4c7d
    style F fill:#6d4c7d
    style G fill:#6d4c7d
    style H fill:#6d4c7d
```

## Beginner Tutorials

### 1. Bell State Circuit

**Level**: 🟢 Beginner  
**Duration**: 15 minutes  
**Topics**: Quantum entanglement, Basic circuits, ConfigMap output

Create and execute your first quantum circuit demonstrating quantum entanglement.

[:octicons-arrow-right-24: Start Tutorial](bell-state.md)

**What you'll learn:**
- Creating a QiskitJob resource
- Using inline circuit code
- Reading results from ConfigMaps
- Understanding quantum entanglement

---

### 2. Grover's Search Algorithm

**Level**: 🟡 Intermediate  
**Duration**: 30 minutes  
**Topics**: Quantum search, Oracle construction, Amplitude amplification

Implement Grover's algorithm to search for marked items in an unsorted database.

[:octicons-arrow-right-24: Start Tutorial](grovers-algorithm.md)

**What you'll learn:**
- Implementing quantum search algorithms
- Constructing quantum oracles
- Understanding quantum speedup
- Analyzing measurement results

---

## Intermediate Tutorials

### 3. VQE for Quantum Chemistry

**Level**: 🟡 Intermediate  
**Duration**: 45 minutes  
**Topics**: VQE, Quantum chemistry, Sessions, IBM Quantum

Use Variational Quantum Eigensolver to find molecular ground states.

[:octicons-arrow-right-24: Start Tutorial](vqe-chemistry.md)

**What you'll learn:**
- Implementing VQE algorithm
- Using IBM Quantum sessions
- Working with molecular Hamiltonians
- Analyzing energy convergence

---

### 4. Quantum Teleportation

**Level**: 🟡 Intermediate  
**Duration**: 30 minutes  
**Topics**: Quantum communication, Entanglement, Conditional operations

Implement quantum teleportation protocol to transfer quantum states.

[:octicons-arrow-right-24: Start Tutorial](quantum-teleportation.md)

**What you'll learn:**
- Creating entangled pairs
- Bell measurements
- Conditional quantum operations
- State verification

---

## Advanced Tutorials

### 5. Cost Optimization Strategies

**Level**: 🔴 Advanced  
**Duration**: 1 hour  
**Topics**: Budget management, Backend selection, Cost optimization

Master cost management features for production quantum computing.

[:octicons-arrow-right-24: Start Tutorial](cost-optimization.md)

**What you'll learn:**
- Setting up budgets and alerts
- Smart backend selection
- Cost-aware circuit design
- Monitoring and reporting

---

### 6. Multi-Backend Configuration

**Level**: 🔴 Advanced  
**Duration**: 45 minutes  
**Topics**: Multiple backends, Failover, Load balancing

Configure and manage multiple quantum backends for high availability.

[:octicons-arrow-right-24: Start Tutorial](multi-backend.md)

**What you'll learn:**
- Configuring multiple backends
- Automatic failover strategies
- Load balancing quantum jobs
- Backend health monitoring

---

## DevOps Tutorials

### 7. CI/CD Integration

**Level**: 🔴 Advanced  
**Duration**: 1 hour  
**Topics**: GitHub Actions, Testing, Automation

Integrate Qiskit Operator into your CI/CD pipelines.

[:octicons-arrow-right-24: Start Tutorial](cicd-integration.md)

**What you'll learn:**
- Automated circuit testing
- GitOps for quantum jobs
- Integration with GitHub Actions
- Quantum regression testing

---

### 8. Production Deployment

**Level**: 🔴 Advanced  
**Duration**: 2 hours  
**Topics**: Production setup, HA, Monitoring, Security

Deploy Qiskit Operator for production workloads.

[:octicons-arrow-right-24: Start Tutorial](production-deployment.md)

**What you'll learn:**
- High availability setup
- Production security hardening
- Monitoring and alerting
- Backup and disaster recovery

---

## Tutorial Categories

<div class="grid cards" markdown>

-   :material-atom:{ .lg .middle } **Quantum Algorithms**

    ---

    Learn fundamental quantum algorithms

    - Bell State
    - Grover's Search
    - VQE
    - Quantum Teleportation

-   :material-cash:{ .lg .middle } **Cost Management**

    ---

    Master cost optimization techniques

    - Budget setup
    - Backend selection
    - Cost monitoring
    - Optimization strategies

-   :material-server-network:{ .lg .middle } **Infrastructure**

    ---

    Production deployment and operations

    - Multi-backend setup
    - High availability
    - Monitoring
    - Security

-   :material-test-tube:{ .lg .middle } **Testing & CI/CD**

    ---

    Automate quantum computing workflows

    - Circuit testing
    - GitOps integration
    - Regression testing
    - Automated deployment

</div>

## Quick Reference

### Tutorial Difficulty Levels

| Level | Symbol | Description |
|-------|--------|-------------|
| Beginner | 🟢 | Basic concepts, no prior quantum knowledge needed |
| Intermediate | 🟡 | Requires basic quantum computing understanding |
| Advanced | 🔴 | Advanced quantum concepts and Kubernetes experience |

### Prerequisites

Before starting tutorials, ensure you have:

- [x] Kubernetes cluster access
- [x] Qiskit Operator installed
- [x] kubectl configured
- [x] Basic understanding of YAML
- [ ] IBM Quantum account (for hardware tutorials)

### Setting Up

```bash
# Verify installation
kubectl get pods -n qiskit-operator-system

# Create namespace for tutorials
kubectl create namespace tutorials

# Set context
kubectl config set-context --current --namespace=tutorials
```

## Hands-On Examples

Each tutorial includes:

- **Step-by-step instructions**
- **Complete working code**
- **Expected results**
- **Troubleshooting tips**
- **Additional exercises**

## Additional Learning Resources

### Documentation
- [Getting Started Guide](../getting-started/index.md)
- [User Guide](../user-guide/index.md)
- [API Reference](../reference/index.md)

### External Resources
- [Qiskit Textbook](https://qiskit.org/textbook/)
- [IBM Quantum Learning](https://learning.quantum.ibm.com/)
- [Quantum Computing Stack Exchange](https://quantumcomputing.stackexchange.com/)

### Community
- [GitHub Discussions](https://github.com/quantum-operator/qiskit-operator/discussions)
- [Slack Community](https://quantum-operator.slack.com)
- [Office Hours](https://quantum-operator.io/office-hours)

## Tutorial Format

Each tutorial follows this structure:

1. **Overview**: What you'll learn and prerequisites
2. **Setup**: Required configuration and resources
3. **Implementation**: Step-by-step instructions
4. **Verification**: How to verify results
5. **Exercises**: Additional practice tasks
6. **Troubleshooting**: Common issues and solutions
7. **Next Steps**: Related tutorials and resources

## Contribute a Tutorial

We welcome tutorial contributions! See our [Contributing Guide](../development/contributing.md) for details.

**Tutorial Ideas:**
- Quantum machine learning with Qiskit
- Error mitigation techniques
- Quantum optimization algorithms
- Advanced circuit design patterns

## Get Help

Stuck on a tutorial? We're here to help!

- 💬 [Ask in Discussions](https://github.com/quantum-operator/qiskit-operator/discussions)
- 🐛 [Report Tutorial Issues](https://github.com/quantum-operator/qiskit-operator-docs/issues)
- 💼 [Join Slack](https://quantum-operator.slack.com)

---

**Ready to start?** Begin with the [Bell State tutorial](bell-state.md) →

