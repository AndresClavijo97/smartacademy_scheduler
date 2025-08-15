#!/bin/bash

# Script para iniciar MongoDB para SmartAcademy
# Crea los directorios si no existen
mkdir -p ~/mongodb/data ~/mongodb/logs

# Inicia MongoDB
mongod --dbpath ~/mongodb/data \
       --logpath ~/mongodb/logs/mongod.log \
       --port 27017 \
       --bind_ip 127.0.0.1 \
       --unixSocketPrefix ~/mongodb \
       --fork

echo "MongoDB iniciado en puerto 27017"
echo "Data: ~/mongodb/data"
echo "Logs: ~/mongodb/logs/mongod.log"