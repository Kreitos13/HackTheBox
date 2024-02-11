#!/bin/bash
# Extrae puertos y servicios que corre por ellos, hay que añadirle como parámetro el archivo del que se va a extraer


# Verificar si se proporcionó un archivo como argumento
if [ $# -eq 0 ]; then
    echo "Uso: $0 archivo_nmap_output"
    exit 1
fi

# Archivo de salida de Nmap
archivo="$1"

# Extraer puertos y servicios usando awk
puertos=$(awk -F/ '/open/{print $1}' "$archivo" | column)
servicios=$(grep "open" $archivo)

# Imprimir los resultados y redirigir la salida al archivo
{
echo "Puertos encontrados:"
echo "$puertos"
echo
echo "Servicios encontrados:"
echo "$servicios"
} > portsServices.txt

echo "Los puertos y servicios encontrados se han guardado en portsServices.txt"
