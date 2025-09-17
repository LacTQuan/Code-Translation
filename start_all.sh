#!/bin/bash

echo "🚀 Starting Code Translation Project..."
echo "========================================"

cleanup() {
    echo ""
    echo "🛑 Shutting down all services..."
    kill 0  # Kill all child processes
    exit 0
}

trap cleanup SIGINT

echo "📁 Starting file server on http://localhost:8000..."
cd /mnt/d/code/Research/code_translation
python3 -m http.server 8000 > /dev/null 2>&1 &
FILE_SERVER_PID=$!

echo "🔧 Starting backend API on http://localhost:8080..."
cd /mnt/d/code/Research/code_translation/code/backend
source venv/bin/activate 2>/dev/null || echo "⚠️  Virtual environment not found, using system Python"
python app/main.py > /dev/null 2>&1 &
BACKEND_PID=$!

echo "⚛️  Starting frontend on http://localhost:5173..."
cd /mnt/d/code/Research/code_translation/code/frontend
npm run dev > /dev/null 2>&1 &
FRONTEND_PID=$!

sleep 3

echo ""
echo "✅ All services are running!"
echo "========================================"
echo "🌐 Frontend:        http://localhost:5173"
echo "🔧 Backend API:     http://localhost:8080"
echo "📁 Experiment Files: http://localhost:8000"
echo "📊 Results Dashboard: http://localhost:8000/index.html"
echo ""
echo "📝 API Documentation: http://localhost:8080/docs"
echo "🔍 Health Check:      http://localhost:8080/health"
echo ""
echo "Press CTRL+C to stop all services"
echo "========================================"

wait
