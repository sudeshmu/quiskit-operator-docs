# Contributing to QiskitOperator Documentation

Thank you for your interest in contributing to the QiskitOperator documentation! This guide will help you get started.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Quick Start](#quick-start)
- [How to Contribute](#how-to-contribute)
- [Documentation Style Guide](#documentation-style-guide)
- [Building Documentation](#building-documentation)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the maintainers.

## Quick Start

### Prerequisites

- Python 3.8+
- Git
- Text editor (VS Code, Vim, etc.)

### Setup

1. **Fork the repository**

```bash
# Click "Fork" on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/qiskit-operator-docs
cd qiskit-operator-docs
```

2. **Install dependencies**

```bash
pip install -r requirements.txt
```

3. **Start the development server**

```bash
./scripts/serve-docs.sh
# Or: mkdocs serve
```

4. **Open in browser**

Visit http://localhost:8000 to see the documentation. Changes will auto-reload!

## How to Contribute

### Small Changes (Typos, Clarifications)

For minor fixes:

1. Click "Edit on GitHub" on any documentation page
2. Make your changes directly in the GitHub editor
3. Commit with a descriptive message
4. Submit a pull request

### Larger Changes (New Pages, Major Edits)

For substantial contributions:

1. **Create a feature branch**

```bash
git checkout -b feature/my-awesome-docs
```

2. **Make your changes**

Edit or create markdown files in the `docs/` directory.

3. **Test locally**

```bash
./scripts/serve-docs.sh
```

Visit http://localhost:8000 and verify your changes.

4. **Validate**

```bash
./scripts/build-docs.sh
```

5. **Commit your changes**

```bash
git add .
git commit -m "docs: add tutorial for XYZ"
```

6. **Push to your fork**

```bash
git push origin feature/my-awesome-docs
```

7. **Create a pull request**

Go to GitHub and create a pull request from your branch.

## Documentation Style Guide

### Writing Style

- **Be clear and concise**: Avoid jargon where possible
- **Use active voice**: "Click the button" not "The button should be clicked"
- **Be inclusive**: Use "they/them" as gender-neutral pronouns
- **Provide context**: Explain why, not just how
- **Show, don't tell**: Include code examples

### Formatting

#### Headings

```markdown
# H1: Page Title
## H2: Major Section
### H3: Subsection
#### H4: Minor Subsection
```

- Use sentence case, not title case
- Don't skip heading levels

#### Code Blocks

Always specify the language:

````markdown
```python
from qiskit import QuantumCircuit
qc = QuantumCircuit(2, 2)
```
````

Common languages:
- `yaml` - Kubernetes YAML
- `python` - Python code
- `bash` - Shell commands
- `json` - JSON data
- `go` - Go code

#### Admonitions

Use for important information:

```markdown
!!! note
    This is important information

!!! warning
    This requires caution

!!! tip
    Helpful advice

!!! danger
    Critical warning
```

#### Links

- **Internal links**: Use relative paths
  ```markdown
  [User Guide](../user-guide/index.md)
  ```

- **External links**: Use full URLs
  ```markdown
  [Qiskit](https://qiskit.org/)
  ```

#### Lists

- **Unordered lists**: Use `-` or `*`
- **Ordered lists**: Use `1.`, `2.`, etc.
- Keep list items parallel in structure

#### Code Inline

Use backticks for:
- Commands: `kubectl apply`
- File names: `qiskitjob.yaml`
- Code references: `QuantumCircuit`

### Example Structure

```markdown
# Tutorial: Creating a Bell State

## Overview

Brief description of what this tutorial covers.

## Prerequisites

- Item 1
- Item 2

## Step 1: Setup

Detailed instructions...

```bash
# Command example
kubectl apply -f example.yaml
```

## Step 2: Execute

More instructions...

```python
# Python example
from qiskit import QuantumCircuit
```

## Expected Output

Show what users should see...

## Troubleshooting

### Issue 1

**Problem**: Description

**Solution**: Fix

## Next Steps

- [Related Tutorial](../other-tutorial.md)
- [API Reference](../reference/api.md)
```

## Building Documentation

### Local Development

```bash
# Serve with auto-reload
./scripts/serve-docs.sh

# Build static site
./scripts/build-docs.sh

# Validate documentation
python3 scripts/validate-docs.py
```

### Directory Structure

```
docs/
├── index.md              # Homepage
├── getting-started/      # Getting Started guides
├── user-guide/           # User guides
├── tutorials/            # Step-by-step tutorials
├── reference/            # API reference
├── examples/             # Code examples
├── deployment/           # Deployment guides
└── stylesheets/          # Custom CSS
```

### Adding a New Page

1. Create markdown file in appropriate directory
2. Add to `mkdocs.yml` navigation:

```yaml
nav:
  - Section:
    - Title: path/to/file.md
```

3. Test locally
4. Submit pull request

## Submitting Changes

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Types:**
- `docs`: Documentation changes
- `fix`: Bug fixes in docs
- `feat`: New documentation features
- `style`: Formatting changes
- `refactor`: Restructuring
- `test`: Adding tests
- `chore`: Maintenance

**Examples:**

```
docs(tutorials): add quantum teleportation tutorial

docs(reference): update QiskitJob API documentation

fix(examples): correct Bell state circuit code

feat(navigation): add new backend guides section
```

### Pull Request Process

1. **Update your branch**

```bash
git fetch origin
git rebase origin/main
```

2. **Push changes**

```bash
git push origin feature/my-awesome-docs
```

3. **Create pull request** on GitHub

Include:
- Clear title
- Description of changes
- Related issue numbers (if applicable)
- Screenshots (for UI changes)

4. **Address review feedback**

Make requested changes and push updates.

5. **Wait for approval**

Maintainers will review and merge when ready.

### PR Checklist

Before submitting:

- [ ] Documentation builds without errors
- [ ] Links work correctly
- [ ] Code examples are tested
- [ ] Spelling and grammar checked
- [ ] Follows style guide
- [ ] Images optimized (if added)
- [ ] Navigation updated (if new page)
- [ ] Tested on mobile (if UI changes)

## Types of Contributions

### 📝 Documentation

- Fix typos and grammatical errors
- Improve clarity and readability
- Add missing information
- Update outdated content

### 💡 Examples

- Add new circuit examples
- Improve existing examples
- Add more use cases
- Include expected outputs

### 📚 Tutorials

- Create step-by-step guides
- Add troubleshooting sections
- Include diagrams and visualizations
- Provide real-world scenarios

### 🎨 Design

- Improve layout
- Add diagrams
- Enhance navigation
- Optimize images

### 🐛 Bug Reports

Found an issue? Please include:

- Page URL
- Description of the issue
- Expected vs. actual content
- Screenshots (if applicable)
- Browser/device (if rendering issue)

### ✨ Feature Requests

Have an idea? Please describe:

- What you want to see
- Why it would be helpful
- Examples from other docs (if available)

## Documentation Standards

### Code Examples

- **Test all code**: Ensure examples work
- **Use realistic scenarios**: Not just "foo" and "bar"
- **Include comments**: Explain non-obvious parts
- **Show output**: What should users expect?
- **Keep updated**: Match current operator version

### YAML Examples

```yaml
# Always include apiVersion and kind
apiVersion: quantum.io/v1
kind: QiskitJob
metadata:
  name: descriptive-name  # Use descriptive names
  namespace: default
spec:
  # Add comments explaining key fields
  backend:
    type: local_simulator
  # ... rest of spec
```

### Screenshots

- Use descriptive file names
- Optimize for web (use tools like TinyPNG)
- Add alt text for accessibility
- Keep up to date with UI changes

### Diagrams

- Use Mermaid for diagrams when possible
- Keep diagrams simple and focused
- Use consistent colors and styles
- Include alt text descriptions

## Getting Help

Need help contributing?

- 💬 [GitHub Discussions](https://github.com/quantum-operator/qiskit-operator/discussions)
- 🐛 [GitHub Issues](https://github.com/quantum-operator/qiskit-operator/issues)
- 📧 Email: docs@quantum-operator.io
- 💬 Slack: [Join our community](https://quantum-operator.slack.com)

## Recognition

Contributors are recognized in:

- [Contributors page](https://github.com/quantum-operator/qiskit-operator-docs/graphs/contributors)
- Release notes
- Documentation footer
- Annual contributor spotlight

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (CC BY 4.0 for documentation, Apache 2.0 for code).

## Resources

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [Markdown Guide](https://www.markdownguide.org/)
- [Qiskit Documentation](https://qiskit.org/documentation/)

## Thank You!

Every contribution helps make quantum computing more accessible. Thank you for being part of our community! 🙏

---

**Questions?** Don't hesitate to ask! We're here to help.

