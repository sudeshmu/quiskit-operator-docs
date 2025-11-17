# Documentation Deployment Guide

This guide will help you deploy the Qiskit Operator documentation website to GitHub Pages.

## Prerequisites

- Python 3.11+
- Git
- GitHub account
- GitHub repository for the documentation

## Local Setup

### 1. Clone Repository

```bash
git clone https://github.com/your-org/qiskit-operator-docs
cd qiskit-operator-docs
```

### 2. Install Dependencies

```bash
# Create virtual environment (optional but recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install requirements
pip install -r requirements.txt
```

### 3. Test Locally

```bash
# Serve documentation locally
mkdocs serve

# Open browser to http://127.0.0.1:8000/
```

The documentation will auto-reload as you make changes.

### 4. Build Static Site

```bash
# Build the static site
mkdocs build

# Output will be in ./site directory
ls -la site/
```

## GitHub Pages Deployment

### Method 1: Automatic Deployment (Recommended)

The repository includes a GitHub Actions workflow that automatically deploys to GitHub Pages on push to `main`.

#### Setup Steps:

1. **Enable GitHub Pages**

   Go to your repository settings:
   - Settings → Pages
   - Source: "GitHub Actions"

2. **Push to Main Branch**

   ```bash
   git add .
   git commit -m "Initial documentation"
   git push origin main
   ```

3. **Verify Deployment**

   - Go to Actions tab in GitHub
   - Watch the deployment workflow run
   - Once complete, visit: `https://your-username.github.io/qiskit-operator-docs/`

The workflow file is located at: `.github/workflows/deploy-docs.yml`

### Method 2: Manual Deployment

If you prefer manual deployment:

```bash
# Build and deploy in one command
mkdocs gh-deploy

# With custom message
mkdocs gh-deploy -m "Update documentation"
```

This will:
1. Build the documentation
2. Create/update the `gh-pages` branch
3. Push to GitHub
4. GitHub Pages will serve from `gh-pages` branch

#### Enable Manual Deployment:

1. **Enable GitHub Pages**
   - Settings → Pages
   - Source: "Deploy from a branch"
   - Branch: "gh-pages" / (root)

2. **Deploy**
   ```bash
   mkdocs gh-deploy
   ```

## Custom Domain (Optional)

### 1. Add CNAME File

Create `docs/CNAME` with your domain:

```
docs.quantum-operator.io
```

### 2. Configure DNS

Add these DNS records to your domain:

**For apex domain (example.com):**
```
A    @    185.199.108.153
A    @    185.199.109.153
A    @    185.199.110.153
A    @    185.199.111.153
```

**For subdomain (docs.example.com):**
```
CNAME    docs    your-username.github.io.
```

### 3. Update mkdocs.yml

```yaml
site_url: https://docs.quantum-operator.io
```

### 4. Enable HTTPS

- Go to Settings → Pages
- Check "Enforce HTTPS"

## Configuration

### Update Site Information

Edit `mkdocs.yml`:

```yaml
site_name: Your Documentation Name
site_url: https://your-domain.com
repo_url: https://github.com/your-org/your-repo
```

### Update Navigation

Modify the `nav` section in `mkdocs.yml` to change the site structure.

### Customize Theme

Edit theme settings in `mkdocs.yml`:

```yaml
theme:
  name: material
  palette:
    primary: deep purple
    accent: purple
  features:
    - navigation.instant
    - navigation.tabs
```

### Add Custom CSS/JS

Place files in:
- `docs/stylesheets/extra.css`
- `docs/javascripts/extra.js`

They're already configured in `mkdocs.yml`.

## Continuous Integration

### GitHub Actions Workflow

The included workflow (`.github/workflows/deploy-docs.yml`) does:

1. **On Pull Request:**
   - Build documentation
   - Check for errors
   - Validate links

2. **On Push to Main:**
   - Build documentation
   - Deploy to GitHub Pages
   - Update live site

### Customize Workflow

Edit `.github/workflows/deploy-docs.yml` to:
- Change trigger branches
- Add additional checks
- Configure deployment options

## Monitoring

### Build Status

Check build status:
- GitHub Actions tab
- Look for green checkmarks

### Access Logs

View deployment logs:
- Actions tab → Select workflow run
- Click on job steps to see details

### Site Analytics

Add Google Analytics in `mkdocs.yml`:

```yaml
extra:
  analytics:
    provider: google
    property: G-XXXXXXXXXX
```

## Troubleshooting

### Build Fails

```bash
# Check for errors locally
mkdocs build --strict --verbose

# Common issues:
# - Missing pages referenced in nav
# - Broken internal links
# - Invalid YAML in mkdocs.yml
```

### GitHub Pages Not Updating

1. **Check Actions Tab**
   - Look for failed workflows
   - Read error messages

2. **Verify GitHub Pages Settings**
   - Settings → Pages
   - Ensure correct source is selected

3. **Clear Cache**
   - Hard refresh browser (Ctrl+Shift+R)
   - Wait a few minutes for CDN to update

### Custom Domain Issues

1. **DNS Not Resolving**
   ```bash
   # Check DNS
   nslookup docs.quantum-operator.io
   dig docs.quantum-operator.io
   ```

2. **HTTPS Certificate**
   - May take up to 24 hours
   - Ensure DNS is configured correctly

### Missing Dependencies

```bash
# Reinstall all dependencies
pip install --upgrade -r requirements.txt

# Or use specific versions
pip install mkdocs==1.5.3 mkdocs-material==9.5.0
```

## Best Practices

### 1. Version Control

```bash
# Never commit build artifacts
echo "site/" >> .gitignore

# Commit source files only
git add docs/ mkdocs.yml
```

### 2. Branch Protection

Protect the `main` branch:
- Settings → Branches
- Add rule for `main`
- Require pull request reviews
- Require status checks to pass

### 3. Preview Deployments

For PRs, consider using:
- Netlify Deploy Previews
- Vercel preview deployments
- GitHub Pages with subdirectories

### 4. Regular Updates

```bash
# Update dependencies monthly
pip install --upgrade -r requirements.txt
pip freeze > requirements.txt

# Test locally
mkdocs build
mkdocs serve

# Commit if working
git commit -am "Update dependencies"
```

### 5. Documentation Review

- Review changes in PR
- Test locally before merging
- Check all links work
- Verify formatting

## Advanced Features

### Search

Material theme includes built-in search. Configure in `mkdocs.yml`:

```yaml
plugins:
  - search:
      separator: '[\s\-,:!=\[\]()"`/]+|\.(?!\d)|&[lg]t;'
```

### Versioning

Use mike for version management:

```bash
# Install mike
pip install mike

# Create version
mike deploy v1.0 latest --update-aliases

# List versions
mike list
```

### PDF Generation

Generate PDF documentation:

```bash
# Install plugin
pip install mkdocs-with-pdf

# Add to mkdocs.yml
plugins:
  - with-pdf
```

## Support

- **Documentation Issues**: Open an issue on GitHub
- **MkDocs Help**: [MkDocs Documentation](https://www.mkdocs.org/)
- **Material Theme**: [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)

## Maintenance

### Regular Tasks

**Weekly:**
- Check for broken links
- Review new issues

**Monthly:**
- Update dependencies
- Review analytics
- Update outdated content

**Quarterly:**
- Major content review
- Update screenshots
- Refresh examples

---

**Need help?** Open an issue or discussion on GitHub!

