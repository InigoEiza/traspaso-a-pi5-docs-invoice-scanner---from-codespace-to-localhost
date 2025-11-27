#!/bin/bash
echo "?? Matando procesos en puertos 4000 y 5177..."
sudo lsof -ti:4000,5177 | xargs -r kill -9
echo "? Puertos liberados correctamente"
