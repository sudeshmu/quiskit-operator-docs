# 🚀 GitHub Pages Setup Instructions

Your documentation has been pushed to GitHub! Follow these steps to deploy it.

## Quick Setup (2 minutes)

### Step 1: Enable GitHub Pages

1. **Go to your repository**: https://github.com/sudeshmu/quiskit-operator-docs

2. **Navigate to Settings**
   - Click the **Settings** tab at the top

3. **Go to Pages section**
   - In the left sidebar, click **Pages** (under "Code and automation")

4. **Configure Source**
   - Under "Build and deployment"
   - **Source**: Select **"GitHub Actions"** (NOT "Deploy from a branch")
   - Click **Save** if prompted

### Step 2: Trigger Deployment

The GitHub Actions workflow will automatically run when you push to `main`. It should start within seconds!

**Check deployment status:**
1. Go to the **Actions** tab: https://github.com/sudeshmu/quiskit-operator-docs/actions
2. You should see a workflow running called "Deploy Documentation"
3. Wait for it to complete (usually 1-2 minutes)

### Step 3: View Your Live Site!

Once the workflow completes successfully (green checkmark), your site will be live at:

🌐 **https://sudeshmu.github.io/quiskit-operator-docs/**

---

## Detailed Visual Guide

### Settings Page
```
Repository → Settings → Pages

┌─────────────────────────────────────┐
│ GitHub Pages                         │
├─────────────────────────────────────┤
│ Build and deployment                 │
│                                      │
│ Source: [GitHub Actions ▼]          │  ← Select this!
│                                      │
│ ✅ Your site is live at:            │
│ https://sudeshmu.github.io/...      │
└─────────────────────────────────────┘
```

### GitHub Actions Workflow

The workflow (`.github/workflows/deploy-docs.yml`) will:
1. ✅ Build the documentation
2. ✅ Run link checks
3. ✅ Deploy to GitHub Pages
4. ✅ Make your site live

---

## Troubleshooting

### Workflow Not Running?

If you don't see the workflow:

1. **Check Actions are enabled**
   - Settings → Actions → General
   - Ensure "Allow all actions and reusable workflows" is selected

2. **Manually trigger workflow**
   - Go to Actions tab
   - Click "Deploy Documentation"
   - Click "Run workflow" button
   - Select "main" branch
   - Click "Run workflow"

### Build Fails?

Check the workflow logs:
1. Go to Actions tab
2. Click on the failed workflow run
3. Click on the job to see error details
4. Common fixes:
   - Ensure all dependencies are in `requirements.txt`
   - Check for syntax errors in `mkdocs.yml`
   - Verify all referenced files exist

### 404 Error on Site?

1. Wait 2-3 minutes after deployment completes
2. Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)
3. Clear browser cache
4. Check Pages settings are correct

---

## Custom Domain (Optional)

Want to use your own domain (e.g., docs.quantum-operator.io)?

### 1. Add CNAME File

Create `docs/CNAME` with your domain:
```
docs.quantum-operator.io
```

### 2. Configure DNS

Add these records to your DNS provider:

**For subdomain (docs.example.com):**
```
Type: CNAME
Name: docs
Value: sudeshmu.github.io.
```

**For apex domain (example.com):**
```
Type: A
Name: @
Value: 185.199.108.153

Type: A
Name: @
Value: 185.199.109.153

Type: A
Name: @
Value: 185.199.110.153

Type: A
Name: @
Value: 185.199.111.153
```

### 3. Enable HTTPS

1. Go to Settings → Pages
2. Check "Enforce HTTPS"
3. Wait 24 hours for certificate provisioning

---

## Updating Your Site

After initial setup, updates are automatic:

```bash
# Make changes to documentation
vim docs/some-page.md

# Commit and push
git add .
git commit -m "Update documentation"
git push origin main

# GitHub Actions will automatically rebuild and deploy!
```

Your site updates in 1-2 minutes after pushing to `main`.

---

## Verification Checklist

- [ ] GitHub Pages source set to "GitHub Actions"
- [ ] Workflow completed successfully (green checkmark)
- [ ] Site is live at: https://sudeshmu.github.io/quiskit-operator-docs/
- [ ] All pages load correctly
- [ ] Search works
- [ ] Navigation works
- [ ] Dark/light mode toggle works

---

## Next Steps

1. ✅ **Share your documentation!**
   - Tweet about it
   - Share in Slack/Discord communities
   - Add link to your README

2. ✅ **Monitor usage**
   - Check GitHub Pages analytics (if enabled)
   - Add Google Analytics (update `mkdocs.yml`)

3. ✅ **Keep it updated**
   - Regular content updates
   - Fix broken links
   - Add new examples

---

## Support

**Issues?**
- 📖 Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- 🐛 [Open an issue](https://github.com/sudeshmu/quiskit-operator-docs/issues)
- 💬 [GitHub Discussions](https://github.com/sudeshmu/quiskit-operator-docs/discussions)

**Resources:**
- [GitHub Pages Docs](https://docs.github.com/en/pages)
- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)

---

## 🎉 Congratulations!

Your Qiskit Operator documentation is now deployed and accessible to the world!

**Live URL**: https://sudeshmu.github.io/quiskit-operator-docs/

---

*Last Updated: November 17, 2025*

