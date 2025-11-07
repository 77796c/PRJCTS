#!/bin/bash

# Note Keeper App - Easy Setup Script
# This script will set everything up automatically!

echo "🚀 Setting up Note Keeper App for ChatGPT..."
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed."
    echo "Please install Node.js from: https://nodejs.org/"
    echo "Download the LTS version (recommended for most users)"
    exit 1
fi

echo "✅ Node.js found: $(node --version)"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
npm install --silent
if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi
echo "✅ Dependencies installed"
echo ""

# Build the app
echo "🔨 Building the app..."
npm run build --silent
if [ $? -ne 0 ]; then
    echo "❌ Failed to build the app"
    exit 1
fi
echo "✅ App built successfully"
echo ""

# Get the current directory
CURRENT_DIR=$(pwd)

echo "🎉 Setup complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 NEXT STEPS - Copy this configuration:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Add this to your ChatGPT MCP configuration:"
echo ""
echo "{"
echo "  \"note-keeper\": {"
echo "    \"command\": \"node\","
echo "    \"args\": [\"${CURRENT_DIR}/dist/server.js\"],"
echo "    \"cwd\": \"${CURRENT_DIR}\""
echo "  }"
echo "}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Your app is installed at: ${CURRENT_DIR}"
echo ""
echo "Need help? Check out EASY_SETUP.md for step-by-step instructions!"
