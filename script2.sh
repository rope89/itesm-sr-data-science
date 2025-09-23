#!/bin/bash

# Script que pregunta continuamente por archivos y hace respaldos

echo "=== SISTEMA DE RESPALDO DE ARCHIVOS ==="
echo "Ingresa nombres de archivos para crear respaldos"
echo "Escribe 'salir' o 'exit' para terminar"
echo "========================================"

while true; do
    # Pedir nombre del archivo
    echo -n "Ingresa el nombre del archivo: "
    read nombre_archivo
    
    # Verificar si el usuario quiere salir
    if [[ "$nombre_archivo" == "salir" || "$nombre_archivo" == "exit" ]]; then
        echo "Saliendo del sistema de respaldo..."
        break
    fi
    
    # Verificar que no este vacio
    if [[ -z "$nombre_archivo" ]]; then
        echo "ERROR: Debes ingresar un nombre de archivo valido"
        continue
    fi
    
    # Verificar si el archivo existe
    if [ -f "$nombre_archivo" ]; then
        # Verificar el tamano del archivo antes del respaldo
        if command -v stat >/dev/null 2>&1; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                tamano_original=$(stat -f%z "$nombre_archivo" 2>/dev/null)
            else
                tamano_original=$(stat -c%s "$nombre_archivo" 2>/dev/null)
            fi
        else
            tamano_original=$(wc -c < "$nombre_archivo" 2>/dev/null)
        fi
        
        # Mostrar informacion del archivo
        if [ -n "$tamano_original" ] && [ "$tamano_original" -ge 0 ] 2>/dev/null; then
            if [ "$tamano_original" -lt 1024 ]; then
                tamano_legible="${tamano_original} bytes"
            elif [ "$tamano_original" -lt 1048576 ]; then
                kb=$((tamano_original / 1024))
                tamano_legible="${kb} KB (${tamano_original} bytes)"
            elif [ "$tamano_original" -lt 1073741824 ]; then
                mb=$((tamano_original / 1048576))
                tamano_legible="${mb} MB (${tamano_original} bytes)"
            else
                gb=$((tamano_original / 1073741824))
                tamano_legible="${gb} GB (${tamano_original} bytes)"
            fi
            echo "Tamano del archivo: $tamano_legible"
        fi
        
        # Generar nombre de respaldo con timestamp
        timestamp=$(date +"%Y%m%d_%H%M%S")
        nombre_respaldo="${nombre_archivo}.backup_${timestamp}"
        
        # Crear el respaldo usando cp con buffer apropiado para archivos grandes
        echo "Creando respaldo..."
        if cp "$nombre_archivo" "$nombre_respaldo" 2>/dev/null; then
            echo "-- Respaldo creado exitosamente: $nombre_respaldo"
            echo "   Archivo original: $nombre_archivo"
            echo "   Archivo respaldo: $nombre_respaldo"
            
            # Verificar integridad del respaldo comparando tamanos
            if command -v stat >/dev/null 2>&1; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    tamano_respaldo=$(stat -f%z "$nombre_respaldo" 2>/dev/null)
                else
                    tamano_respaldo=$(stat -c%s "$nombre_respaldo" 2>/dev/null)
                fi
            else
                tamano_respaldo=$(wc -c < "$nombre_respaldo" 2>/dev/null)
            fi
            
            if [ -n "$tamano_original" ] && [ -n "$tamano_respaldo" ] && [ "$tamano_original" = "$tamano_respaldo" ]; then
                echo "   Integridad verificada: ambos archivos tienen el mismo tamaño"
            elif [ -n "$tamano_original" ] && [ -n "$tamano_respaldo" ]; then
                echo "   ADVERTENCIA: diferencia en tamaños (original: $tamano_original, respaldo: $tamano_respaldo)"
            else
                echo "   No se pudo verificar la integridad del respaldo"
            fi
        else
            echo "ERROR: No se pudo crear el respaldo"
            echo "   Posibles causas: falta de espacio en disco, permisos insuficientes"
        fi
    else
        echo "ERROR: El archivo '$nombre_archivo' no existe en el directorio actual"
        echo "   Verifica que el nombre este correcto y que el archivo exista"
    fi
    
    echo "----------------------------------------"
done

echo "Programa terminado. Gracias por usar el sistema de respaldo!"