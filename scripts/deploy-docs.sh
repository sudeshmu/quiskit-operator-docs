#!/bin/bash
# Deploy documentation to GitHub Pages

set -e

echo "🚀 Deploying QiskitOperator Documentation"
echo "========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}⚠️  Warning: You are on branch '$CURRENT_BRANCH', not 'main'${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled"
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes${NC}"
    git status --short
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled"
        exit 1
    fi
fi

# Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
pip3 install -q -r requirements.txt
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Validate documentation
echo "🔍 Validating documentation..."
if python3 scripts/validate-docs.py; then
    echo -e "${GREEN}✅ Documentation validated${NC}"
else
    echo -e "${RED}❌ Documentation validation failed${NC}"
    exit 1
fi
echo ""

# Build documentation
echo "🏗️  Building documentation..."
if mkdocs build --strict; then
    echo -e "${GREEN}✅ Documentation built${NC}"
else
    echo -e "${RED}❌ Documentation build failed${NC}"
    exit 1
fi
echo ""

# Show site statistics
SITE_SIZE=$(du -sh site | cut -f1)
TOTAL_FILES=$(find site -type f | wc -l)
echo "📊 Site Statistics:"
echo "  Size: $SITE_SIZE"
echo "  Files: $TOTAL_FILES"
echo ""

# Confirm deployment
echo -e "${YELLOW}🚀 Ready to deploy to GitHub Pages${NC}"
read -p "Deploy now? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

# Deploy to GitHub Pages
echo "🚀 Deploying to GitHub Pages..."
if mkdocs gh-deploy --force; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo ""
    echo "🌐 Documentation will be available at:"
    echo "   https://quantum-operator.github.io/qiskit-operator/"
    echo ""
    echo "⏱️  It may take a few minutes for changes to appear"
else
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi

