# Qiskit Operator Documentation

This repository contains the official documentation for [Qiskit Operator](https://github.com/quantum-operator/qiskit-operator), a production-ready Kubernetes operator for IBM Qiskit quantum computing workloads.

## 🌐 Live Documentation

Visit the live documentation at: **[https://quantum-operator.github.io/qiskit-operator](https://quantum-operator.github.io/qiskit-operator)**

## 📚 Documentation Structure

```
docs/
├── index.md                    # Homepage
├── getting-started/            # Getting started guides
│   ├── index.md
│   ├── quick-start.md
│   ├── installation.md
│   ├── first-job.md
│   └── local-development.md
├── user-guide/                 # Comprehensive user guide
│   ├── quantum-jobs.md
│   ├── backends.md
│   ├── sessions.md
│   └── ...
├── tutorials/                  # Step-by-step tutorials
│   ├── bell-state.md
│   ├── grovers-algorithm.md
│   └── ...
├── reference/                  # API reference
│   ├── qiskitjob.md
│   ├── qiskitbackend.md
│   └── ...
├── deployment/                 # Deployment guides
│   ├── docker.md
│   ├── kubernetes.md
│   └── ...
└── development/                # Development guides
    ├── contributing.md
    ├── building.md
    └── ...
```

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- pip

### Local Development

1. **Clone the repository**

```bash
git clone https://github.com/quantum-operator/qiskit-operator-docs
cd qiskit-operator-docs
```

2. **Install dependencies**

```bash
pip install -r requirements.txt
```

3. **Serve documentation locally**

```bash
mkdocs serve
```

The documentation will be available at `http://127.0.0.1:8000/`

### Building Documentation

```bash
# Build static site
mkdocs build

# Output will be in ./site directory
ls -la site/
```

## 📝 Contributing

We welcome contributions to improve the documentation!

### Making Changes

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b docs/improve-section
   ```
3. **Make your changes**
   - Edit files in `docs/`
   - Test locally with `mkdocs serve`
4. **Commit your changes**
   ```bash
   git commit -m "docs: improve getting started section"
   ```
5. **Push to your fork**
   ```bash
   git push origin docs/improve-section
   ```
6. **Open a Pull Request**

### Writing Guidelines

- Use clear, concise language
- Include code examples where relevant
- Add diagrams using Mermaid when helpful
- Follow the existing structure and style
- Test all code examples before committing

## 🛠️ Technology Stack

- **[MkDocs](https://www.mkdocs.org/)**: Static site generator
- **[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)**: Beautiful theme
- **[Mermaid](https://mermaid.js.org/)**: Diagram generation
- **[Pygments](https://pygments.org/)**: Syntax highlighting
- **[GitHub Pages](https://pages.github.com/)**: Hosting

## 📦 Deployment

Documentation is automatically deployed to GitHub Pages when changes are pushed to the `main` branch.

### Manual Deployment

```bash
# Build and deploy
mkdocs gh-deploy

# With custom commit message
mkdocs gh-deploy -m "Update documentation"
```

## 🔍 Search

The documentation includes full-text search powered by MkDocs Material's built-in search functionality.

## 🌍 Localization

Currently available in:
- 🇺🇸 English (default)

We welcome contributions for additional languages!

## 📄 License

This documentation is licensed under the [Apache License 2.0](LICENSE).

The Qiskit Operator project is also licensed under the [Apache License 2.0](https://github.com/quantum-operator/qiskit-operator/blob/main/LICENSE).

## 🤝 Support

- **Documentation Issues**: [Open an issue](https://github.com/quantum-operator/qiskit-operator-docs/issues)
- **Operator Issues**: [Open an issue](https://github.com/quantum-operator/qiskit-operator/issues)
- **Discussions**: [GitHub Discussions](https://github.com/quantum-operator/qiskit-operator/discussions)
- **Slack**: [Join our community](https://quantum-operator.slack.com)

## 🔗 Related Links

- [Qiskit Operator GitHub](https://github.com/quantum-operator/qiskit-operator)
- [Docker Hub](https://hub.docker.com/r/sudeshmu/qiskit-operator)
- [Qiskit Documentation](https://qiskit.org/documentation/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 📊 Statistics

![GitHub last commit](https://img.shields.io/github/last-commit/quantum-operator/qiskit-operator-docs)
![GitHub contributors](https://img.shields.io/github/contributors/quantum-operator/qiskit-operator-docs)
![GitHub issues](https://img.shields.io/github/issues/quantum-operator/qiskit-operator-docs)

## 🙏 Acknowledgments

- IBM Qiskit team for their excellent quantum computing framework
- MkDocs and Material for MkDocs teams for the documentation tools
- All contributors who help improve this documentation

---

**Built with ❤️ by the Quantum Operator Team**

*Making quantum computing documentation accessible to everyone*

