#!/bin/bash

# AI Support Agent - Startup Script
# This script starts the FastAPI server with proper configuration

echo "🚀 Starting AI Support Agent..."
echo "================================"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "⚠️  Virtual environment not found."
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created."
fi

# Activate virtual environment
echo "📦 Activating virtual environment..."
source venv/bin/activate

# Check if requirements are installed
if [ ! -f "venv/lib/python*/site-packages/fastapi/__init__.py" ]; then
    echo "📥 Installing dependencies..."
    pip install -r requirements.txt
    echo "✅ Dependencies installed."
fi

# Check for .env file
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found!"
    echo "Creating template .env file..."
    cat > .env << EOF
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Model Configuration
MODEL_NAME=gpt-4o-mini
TEMPERATURE=0.0
MAX_TOKENS=1000

# Agent Configuration
MAX_ITERATIONS=5
VERBOSE_MODE=false

# Context Compression
COMPRESSION_THRESHOLD=5
COMPRESSION_MODEL=gpt-4o-mini

# Server Configuration
HOST=0.0.0.0
PORT=8000

# Rate Limiting
RATE_LIMIT_PER_MINUTE=60
EOF
    echo "✅ Template .env file created."
    echo "⚠️  Please edit .env and add your OPENAI_API_KEY"
    echo ""
    read -p "Press Enter after updating .env file..."
fi

# Start the server
echo "🌐 Starting FastAPI server..."
echo "================================"
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Cleanup on exit
deactivate
