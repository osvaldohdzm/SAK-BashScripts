#!/bin/bash

# Ruta del directorio donde se encuentran los archivos de objetivos
TARGET_DIR="Archivos_operativos/targets"

# Ruta del directorio donde se almacenarán los resultados
OUTPUT_DIR="$(pwd)/Archivos_operativos/zaproxy"

# Obtener la fecha actual
DATE=$(date +"%Y-%m-%d-%I-%M-%p")

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
    OUTPUT_FILE="${OUTPUT_DIR}/${PROTOCOL}_${FQDN}-${DATE}.html"

    # Escanear con ZAP
    zaproxy -cmd -quickurl "${PROTOCOL}://${FQDN}" -quickprogress -quickout "$OUTPUT_FILE"
done < "$TARGET_DIR/URLs.txt"
