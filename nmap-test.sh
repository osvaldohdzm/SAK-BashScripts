#!/bin/bash

# Verificar si se está ejecutando como root (con sudo)
if [ "$(id -u)" != "0" ]; then
    echo "Este script requiere privilegios de superusuario. Por favor, ejecútalo con sudo."
    exit 1
fi

# Verificar si nmap está instalado
if ! command -v nmap &> /dev/null; then
    echo "Nmap no está instalado. Instalando Nmap..."
    apt-get update
    apt-get install -y nmap
fi

# Solicitar al usuario la dirección IP de destino
read -p "Ingresa la dirección IP de destino: " targetIP

# Solicitar el valor mínimo de min-rate
read -p "Ingresa el valor mínimo de min-rate a probar: " minMinRate

# Solicitar el valor máximo de min-rate
read -p "Ingresa el valor máximo de min-rate a probar: " maxMinRate

# Inicializar variables para el mejor min-rate y tiempo mínimo registrado
bestMinRate=0
minTime=999999

# Bucle de búsqueda binaria
while [ "$minMinRate" -lt "$maxMinRate" ]; do
    # Calcular el valor medio de min-rate
    currentMinRate=$((minMinRate + (maxMinRate - minMinRate) / 2))

    # Ejecutar Nmap con el valor actual de min-rate y medir el tiempo
    echo "Probando con min-rate = $currentMinRate..."
    result=$(nmap -T5 --min-rate "$currentMinRate" "$targetIP" 2>&1)
    timeTaken=$(echo "$result" | grep -oP 'scanned in \K[0-9.]+' | head -1)

    echo "Escaneo completado en $timeTaken segundos."

    # Comparar el tiempo actual con el tiempo mínimo registrado
    if (( $(echo "$timeTaken < $minTime" | bc -l) )); then
        minTime="$timeTaken"
        bestMinRate="$currentMinRate"
    fi

    # Actualizar los valores mínimo y máximo de min-rate
    if (( $(echo "$timeTaken < $minTime" | bc -l) )); then
        maxMinRate="$currentMinRate"
    else
        minMinRate="$((currentMinRate + 1))"
    fi
done

# Imprimir el mejor valor de min-rate encontrado
echo "El mejor valor de min-rate encontrado es: $bestMinRate"
