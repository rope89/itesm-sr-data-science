#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Uso: $0 archivo1 archivo2 archivo3 ..."
    echo "Este script busca los archivos especificados y muestra su tamaño"
    exit 1
fi

echo "Verificando archivos en el directorio actual..."
echo "============================================="

# Recorrer cada parametro
for archivo in "$@"; do
    echo -n "Archivo '$archivo': "
    if [ -f "$archivo" ]; then
        if command -v stat >/dev/null 2>&1; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                size=$(stat -f%z "$archivo" 2>/dev/null)
            else
                # Linux y otros Unix
                size=$(stat -c%s "$archivo" 2>/dev/null)
            fi
            
            if [ $? -eq 0 ] && [ -n "$size" ]; then
                # Formatear el tamaño de manera legible
                if [ "$size" -lt 1024 ]; then
                    echo "${size} bytes"
                elif [ "$size" -lt 1048576 ]; then
                    kb=$((size / 1024))
                    echo "${size} bytes (${kb} KB)"
                elif [ "$size" -lt 1073741824 ]; then
                    mb=$((size / 1048576))
                    echo "${size} bytes (${mb} MB)"
                else
                    gb=$((size / 1073741824))
                    echo "${size} bytes (${gb} GB)"
                fi
            else
                echo "Error al obtener el tamaño"
            fi
        else
            size=$(wc -c < "$archivo" 2>/dev/null)
            if [ $? -eq 0 ] && [ -n "$size" ]; then
                if [ "$size" -lt 1024 ]; then
                    echo "${size} bytes"
                elif [ "$size" -lt 1048576 ]; then
                    kb=$((size / 1024))
                    echo "${size} bytes (${kb} KB)"
                elif [ "$size" -lt 1073741824 ]; then
                    mb=$((size / 1048576))
                    echo "${size} bytes (${mb} MB)"
                else
                    gb=$((size / 1073741824))
                    echo "${size} bytes (${gb} GB)"
                fi
            else
                echo "Error al obtener el tamaño"
            fi
        fi
    else
        echo "No encontrado en el directorio actual"
    fi
done

echo "============================================="
echo "Verificación completada."