#!/bin/bash
# Serve documentation locally

set -e

echo "🚀 Starting Documentation Server"
echo "================================"
echo ""

# Check if requirements are installed
if ! python3 -c "import mkdocs" 2>/dev/null; then
    echo "📦 Installing dependencies..."
    pip3 install -r requirements.txt
    echo ""
fi

# Check for available port
PORT=8000
while lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; do
    echo "⚠️  Port $PORT is in use, trying $((PORT+1))..."
    PORT=$((PORT+1))
done

echo "🌐 Starting server on http://localhost:$PORT"
echo ""
echo "📝 Documentation will auto-reload on file changes"
echo "Press Ctrl+C to stop"
echo ""

# Serve with specified port
mkdocs serve --dev-addr=localhost:$PORT

