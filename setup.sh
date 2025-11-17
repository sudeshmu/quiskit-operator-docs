#!/bin/bash

# Qiskit Operator Documentation - Setup Script
# This script sets up the documentation environment and optionally deploys to GitHub Pages

set -e

echo "🚀 Qiskit Operator Documentation Setup"
echo "========================================"
echo ""

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.11+"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "✅ Python version: $PYTHON_VERSION"

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
else
    echo "✅ Virtual environment already exists"
fi

# Activate venv
echo "🔄 Activating virtual environment..."
source venv/bin/activate || {
    echo "❌ Failed to activate virtual environment"
    exit 1
}

# Install dependencies
echo "📥 Installing dependencies..."
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt > /dev/null 2>&1
echo "✅ Dependencies installed"

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo ""
    echo "❓ Initialize Git repository? (y/n)"
    read -r INIT_GIT
    if [ "$INIT_GIT" = "y" ]; then
        echo "🔧 Initializing Git repository..."
        git init
        git add .
        git commit -m "Initial commit: Qiskit Operator documentation"
        echo "✅ Git repository initialized"
        
        echo ""
        echo "❓ Add GitHub remote? (y/n)"
        read -r ADD_REMOTE
        if [ "$ADD_REMOTE" = "y" ]; then
            echo "📝 Enter your GitHub repository URL (e.g., https://github.com/user/repo.git):"
            read -r REPO_URL
            git remote add origin "$REPO_URL"
            echo "✅ Remote added: $REPO_URL"
            
            echo ""
            echo "❓ Push to GitHub? (y/n)"
            read -r DO_PUSH
            if [ "$DO_PUSH" = "y" ]; then
                git branch -M main
                git push -u origin main
                echo "✅ Pushed to GitHub"
            fi
        fi
    fi
fi

# Test build
echo ""
echo "🔨 Testing documentation build..."
mkdocs build --strict --verbose > /dev/null 2>&1 && {
    echo "✅ Documentation builds successfully"
} || {
    echo "⚠️  Build has warnings or errors. Running verbose build..."
    mkdocs build --strict --verbose
}

# Ask about local server
echo ""
echo "❓ Start local development server? (y/n)"
read -r START_SERVER
if [ "$START_SERVER" = "y" ]; then
    echo "🌐 Starting local server at http://127.0.0.1:8000/"
    echo "   Press Ctrl+C to stop"
    echo ""
    mkdocs serve
else
    echo ""
    echo "✅ Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Start development server: mkdocs serve"
    echo "  2. Build static site: mkdocs build"
    echo "  3. Deploy to GitHub Pages: mkdocs gh-deploy"
    echo ""
    echo "📖 See DEPLOYMENT_GUIDE.md for detailed instructions"
fi

echo ""
echo "🎉 Qiskit Operator Documentation is ready!"

