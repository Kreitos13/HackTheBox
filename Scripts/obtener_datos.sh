#!/bin/bash
# Hay que añadirle como parámetro la IP que tenga el puerto 161 snmp abierto

if [ $# -ne 1 ]; then
    echo "Uso: $0 <archivo>"
    exit 1
fi

archivo="$1"

# Verifica si el archivo de entrada existe
if [ ! -f "$archivo" ]; then
    echo "Error: El archivo $archivo no existe."
    exit 1
fi

# Filtra los datos que están detrás de "STRING:", "Hex-STRING:", e "IpAddress:" usando awk
awk '/(STRING|Hex-STRING|IpAddress):/ {print $0}' "$archivo"