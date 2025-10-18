#!/bin/bash

echo "========================================"
echo "  MindVault Local Testing Server"
echo "========================================"
echo ""
echo "Starting local web server..."
echo ""
echo "Open your browser and go to:"
echo "  http://localhost:8000"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""
echo "========================================"
echo ""

# Get the directory where the script is located
cd "$(dirname "$0")"

# Try Python 3 first
if command -v python3 &> /dev/null; then
    echo "Using Python 3..."
    python3 -m http.server 8000
elif command -v python &> /dev/null; then
    echo "Using Python..."
    python -m http.server 8000
else
    echo "Python not found. Please install Python 3.x"
    echo "Download from: https://www.python.org/downloads/"
    exit 1
fi

