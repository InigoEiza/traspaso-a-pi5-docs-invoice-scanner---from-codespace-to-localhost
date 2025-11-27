#!/bin/bash

echo "Iniciando SmartHome Backend + Frontend..."

# Obtener IP local (la primera interfaz activa, suele ser wlan0 o eth0)
IP_LOCAL=$(hostname -I | awk '{print $1}')
echo "IP local detectada: $IP_LOCAL"

# Iniciar Backend en puerto 4000
echo "Iniciando Backend en puerto 4000..."
cd backend
npm run dev -- --port 4000 &
BACKEND_PID=$!
cd ..

# Iniciar Frontend (Vite normalmente en puerto 5175, o 3000 si es create-react-app)
echo "Iniciando Frontend..."
cd frontend   # ← cambia "frontend" si tu carpeta tiene otro nombre
npm run dev &   # o "npm start" si es create-react-app
FRONTEND_PID=$!
cd ..

echo "=========================================="
echo "Backend PID : $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "URLs locales (desde cualquier dispositivo en tu WiFi):"
echo "   Frontend → http://$IP_LOCAL:5175"
echo "   Backend  → http://$IP_LOCAL:4000"
echo ""
echo "Desde tu móvil con VNC Viewer:"
echo "   1. Abre el navegador del escritorio remoto (Chromium)"
echo "   2. Pon exactamente estas direcciones:"
echo "      • Frontend: http://localhost:5175"
echo "      • Backend : http://localhost:4000"
echo "=========================================="

# Mantener el script vivo hasta que pulses Ctrl+C
wait
