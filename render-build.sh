#!/bin/bash
# Render build hook: install system dependencies for code judging
# This runs during the build phase to install Python3 and g++ for programming question evaluation

echo "=== Installing code judge dependencies ==="

# Install Python3 and g++ if available
if command -v apt-get &> /dev/null; then
    apt-get update -qq
    apt-get install -y -qq python3 g++ > /dev/null 2>&1 || true
elif command -v yum &> /dev/null; then
    yum install -y python3 gcc-c++ > /dev/null 2>&1 || true
elif command -v apk &> /dev/null; then
    apk add --no-cache python3 g++ > /dev/null 2>&1 || true
fi

# Verify installations
echo "Python3: $(python3 --version 2>&1 || echo 'not found')"
echo "g++: $(g++ --version 2>&1 | head -1 || echo 'not found')"

echo "=== Code judge dependencies installed ==="
