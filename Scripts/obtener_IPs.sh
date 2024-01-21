#!/bin/bash
# Hay que añadirle como parámetro el fichero de subdominios al que le va a extraer las IPs

if [ $# -ne 1 ]; then
    echo "Uso: $0 <archivo_subdominios>"
    exit 1
fi

input_file="$1"
output_file="subdomain_IPs.txt"

# Verifica si el archivo de entrada existe
if [ ! -f "$input_file" ]; then
    echo "Error: El archivo $input_file no existe."
    exit 1
fi

# Bucle para procesar cada subdominio y obtener la IP
while IFS= read -r subdominio; do
    ip=$(dig +short "$subdominio" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}')
    if [ -n "$ip" ]; then
        echo "$subdominio: $ip"
        echo "$ip" >> "$output_file"
    else
        echo "No se pudo obtener la IP para $subdominio"
    fi
done < "$input_file"

echo "Proceso completado. Las IPs se han guardado en $output_file."