#!/bin/bash

url_file='Archivos_operativos/metagoofil/metadata-files-urls.txt'
download_folder='Archivos_operativos/metagoofil'
output_file='Archivos_operativos/metagoofil/metadata-output.csv'
counter=1

# Crear la carpeta de descarga si no existe
if [ ! -d "$download_folder" ]; then
    mkdir "$download_folder"
fi

# Eliminar el archivo de salida si ya existe
if [ -f "$output_file" ]; then
    rm "$output_file"
fi

# Escribir la línea de encabezado en el archivo de salida
echo 'URL,File,MIMEType,FileSize,Author,Creator,Producer' >> "$output_file"

# Recorrer cada línea en el archivo de URL
while read -r line; do
    # Descargar el archivo
    filename="$counter.$(echo "$line" | awk -F/ '{print $NF}' | awk -F. '{print $NF}')"
    echo "$filename"
    wget --tries=3 --no-check-certificate -P "$download_folder" -O "$download_folder/$filename" "$line" || rm - "$download_folder/$filename"

    # Obtener los datos EXIF
    exif_data=$(exiftool -csv -MIMEType -FileSize -Author -Creator -Producer "$download_folder/$filename" | tail -n +2 | iconv -t UTF-8)

    # Agregar los datos al archivo de salida
    if [ -e "$download_folder/$filename" ]; then
        echo "\"$line\",$exif_data" >> "$output_file"
    fi

    counter=$((counter+1))
done < "$url_file"
