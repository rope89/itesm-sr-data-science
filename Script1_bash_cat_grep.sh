#!/bin/bash

# Script que busca archivos con patron y crea archivo con listado
# Uso: ./script.sh nombre_archivo patron

# Funcion para buscar patron en archivos y crear listado
crear_listado_archivos() {
    local nombre_archivo="$1"
    local patron="$2"
    
    # Verificar que se proporcionaron ambos parametros
    if [ -z "$nombre_archivo" ] || [ -z "$patron" ]; then
        echo "ERROR: Se requieren dos parametros"
        echo "Uso: crear_listado_archivos nombre_archivo patron"
        return 1
    fi
    
    # Limpiar archivo si existe
    > "$nombre_archivo"
    
    echo "Buscando patron '$patron' en archivos del directorio actual..."
    echo "Creando archivo: $nombre_archivo"
    echo "========================================="
    
    # Contador de archivos encontrados
    contador=0
    
    # Escribir encabezado en el archivo
    echo "# Listado de archivos que contienen el patron: $patron" > "$nombre_archivo"
    echo "# Generado el: $(date)" >> "$nombre_archivo"
    echo "# Directorio: $(pwd)" >> "$nombre_archivo"
    echo "=========================================" >> "$nombre_archivo"
    echo "" >> "$nombre_archivo"
    
    # Buscar patron en todos los archivos del directorio actual
    for archivo in *; do
        # Verificar que sea un archivo regular (no directorio)
        if [ -f "$archivo" ]; then
            # Buscar el patron en el archivo usando grep
            if grep -q "$patron" "$archivo" 2>/dev/null; then
                echo "  Encontrado en: $archivo"
                echo "$archivo" >> "$nombre_archivo"
                contador=$((contador + 1))
            fi
        fi
    done
    
    # Agregar resumen al final del archivo
    echo "" >> "$nombre_archivo"
    echo "=========================================" >> "$nombre_archivo"
    echo "# Total de archivos encontrados: $contador" >> "$nombre_archivo"
    
    # Mostrar resumen en pantalla
    echo "========================================="
    echo "RESUMEN:"
    echo "  Archivos encontrados: $contador"
    echo "  Archivo creado: $nombre_archivo"
    
    # Mostrar contenido del archivo creado
    if [ $contador -gt 0 ]; then
        echo ""
        echo "Contenido del archivo '$nombre_archivo':"
        echo "----------------------------------------"
        cat "$nombre_archivo"
    else
        echo ""
        echo "No se encontraron archivos con el patron '$patron'"
        echo "El archivo '$nombre_archivo' fue creado vacio"
    fi
    
    return 0
}

# Verificar numero de parametros del script
if [ $# -ne 2 ]; then
    echo "ERROR: Numero incorrecto de parametros"
    echo "Uso: $0 nombre_archivo patron"
    echo ""
    echo "Ejemplo:"
    echo "  $0 archivos_con_error.txt 'error'"
    echo "  $0 scripts_python.txt '.py'"
    echo "  $0 configs.txt 'config'"
    exit 1
fi

# Obtener parametros
nombre_archivo="$1"
patron="$2"

# Validar que el nombre del archivo no este vacio
if [ -z "$nombre_archivo" ]; then
    echo "ERROR: El nombre del archivo no puede estar vacio"
    exit 1
fi

# Validar que el patron no este vacio
if [ -z "$patron" ]; then
    echo "ERROR: El patron de busqueda no puede estar vacio"
    exit 1
fi

# Mostrar informacion inicial
echo "=== BUSCADOR DE PATRONES EN ARCHIVOS ==="
echo "Parametros recibidos:"
echo "  Archivo de salida: '$nombre_archivo'"
echo "  Patron de busqueda: '$patron'"
echo "  Directorio actual: $(pwd)"
echo ""

# Llamar a la funcion principal
crear_listado_archivos "$nombre_archivo" "$patron"

# Verificar si la funcion se ejecuto correctamente
if [ $? -eq 0 ]; then
    echo ""
    echo "Script ejecutado exitosamente!"
else
    echo ""
    echo "ERROR: Hubo un problema durante la ejecucion"
    exit 1
fi      