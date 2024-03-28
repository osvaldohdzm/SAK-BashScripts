#!/bin/bash

# Ruta del directorio donde se encuentran los archivos de objetivos
TARGET_DIR="Archivos_operativos/targets"

# Ruta del directorio donde se almacenarán los resultados (relativa al directorio de ejecución)
OUTPUT_DIR="$(pwd)/Archivos_operativos/dirb"

# Obtener la fecha actual
DATE=$(date +"%Y-%m-%d-%I-%M-%p")

# Crear el directorio de salida si no existe
mkdir -p "$OUTPUT_DIR"

# Leer cada FQDN desde el archivo URLs.txt
while IFS= read -r FQDN; do
    # Verificar la accesibilidad por HTTP y HTTPS
    if curl --output /dev/null --silent --head --fail "$FQDN"; then
        PROTOCOL="http"
    elif curl --output /dev/null --silent --head --fail "https://$FQDN"; then
        PROTOCOL="https"
    else
        echo "El FQDN $FQDN no es accesible por HTTP ni HTTPS."
        continue
    fi

    # Generar nombre de archivo de salida
    OUTPUT_FILE="${OUTPUT_DIR}/${PROTOCOL}_${FQDN}-${DATE}.txt"

    # Ejecutar dirb
    dirb "${PROTOCOL}://${FQDN}" /usr/share/wordlists/dirb/common.txt -o "$OUTPUT_FILE"
done < "$TARGET_DIR/URLs.txt"
