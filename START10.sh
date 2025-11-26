#!/bin/bash
echo "🚀 Iniciando SmartHome Backend + Frontend..."

echo "▶️ Iniciando Backend en puerto 4000..."
cd backend
npm run dev -- --port 4000 &
BACKEND_PID=$!
cd ..

echo "▶️ Iniciando Frontend en puerto 5175 accesible en red..."
cd frontend
npm run dev -- --host 0.0.0.0 --port 5175 &
FRONTEND_PID=$!
cd ..

echo "📌 Backend PID: $BACKEND_PID"
echo "📌 Frontend PID: $FRONTEND_PID"

IP=$(hostname -I | awk '{print $1}')
echo "🌍 Acceso desde cualquier dispositivo en la red/Tailscale:"
echo "    Frontend → http://$IP:5175/"
echo "    Backend  → http://$IP:4000/"

echo "⚙️ Para detener todo: Ctrl + C"
wait
