#!/bin/bash

echo "Iniciando SmartHome Backend + Frontend..."

# Obtener la IP local (la primera que no sea loopback)
IP=$(hostname -I | awk '{print $1}')
if [ -z "$IP" ]; then
    IP="127.0.0.1"
    echo "Advertencia: No se detectó IP de red. Usando localhost."
fi

# Abrir puertos en el firewall (solo la primera vez los crea, luego solo verifica)
echo "Abriendo puertos 4000 (backend) y 5177 (frontend) en el firewall..."
sudo ufw allow 4000/tcp >/dev/null 2>&1
sudo ufw allow 5177/tcp >/dev/null 2>&1
# Si es la primera vez que usas UFW, activarlo (comenta la línea si ya lo tienes activo)
# sudo ufw --force enable

# Iniciar backend
echo "Iniciando Backend en puerto 4000..."
cd backend
npm run dev -- --port 4000 &
BACKEND_PID=$!
cd ..

# Iniciar frontend
echo "Iniciando Frontend en puerto 5177..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

# Mostrar información
echo "¡Listo!"
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "Desde tu móvil (con VNC Viewer conectado):"
echo "  Abre el navegador y ve a:"
echo "  Frontend: http://$IP:5177/"
echo "  Backend:  http://$IP:4000/"
echo ""
echo "Los puertos 4000 y 5177 ya están abiertos. Puedes acceder desde cualquier dispositivo en la misma WiFi."
echo "Para detener todo: mata los procesos con 'kill $BACKEND_PID $FRONTEND_PID'"

# Mantener el script vivo hasta que pulses Ctrl+C
wait