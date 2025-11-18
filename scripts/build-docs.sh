#!/bin/bash
# Build documentation script

set -e

echo "🚀 Building QiskitOperator Documentation"
echo "========================================"
echo ""

# Check if running in CI
if [ -n "$CI" ]; then
    echo "Running in CI environment"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Python version
echo "📦 Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
REQUIRED_VERSION="3.8.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo -e "${RED}❌ Python $REQUIRED_VERSION or higher is required (found $PYTHON_VERSION)${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Python $PYTHON_VERSION${NC}"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
pip3 install -q --upgrade pip
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
if mkdocs build --strict --verbose; then
    echo -e "${GREEN}✅ Documentation built successfully${NC}"
else
    echo -e "${RED}❌ Documentation build failed${NC}"
    exit 1
fi
echo ""

# Check output size
SITE_SIZE=$(du -sh site | cut -f1)
echo "📊 Site size: $SITE_SIZE"
echo ""

# List generated files
echo "📁 Generated files:"
find site -type f | head -n 10
TOTAL_FILES=$(find site -type f | wc -l)
echo "... and $(($TOTAL_FILES - 10)) more files"
echo ""

echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo "To serve locally, run:"
echo "  mkdocs serve"
echo ""
echo "To deploy, run:"
echo "  mkdocs gh-deploy"

