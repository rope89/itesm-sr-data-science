#!/bin/bash

# Script que busca patron en todos los archivos y muestra linea y numero de linea
# Uso: ./script2.sh patron

# Funcion para buscar patron con numero de linea
buscar_patron_con_lineas() {
    local patron="$1"
    
    # Verificar que se proporciono el patron
    if [ -z "$patron" ]; then
        echo "ERROR: Se requiere un patron de busqueda"
        echo "Uso: buscar_patron_con_lineas patron"
        return 1
    fi
    
    echo "Buscando patron '$patron' en todos los archivos del directorio actual..."
    echo "Formato: ARCHIVO:NUMERO_LINEA:CONTENIDO_LINEA"
    echo "================================================================"
    
    # Contadores para estadisticas
    local archivos_procesados=0
    local archivos_con_coincidencias=0
    local total_coincidencias=0
    local archivos_con_coincidencias_lista=""
    
    # Procesar todos los archivos en el directorio actual
    for archivo in *; do
        # Verificar que sea un archivo regular
        if [ -f "$archivo" ]; then
            archivos_procesados=$((archivos_procesados + 1))
            
            # Usar grep para buscar el patron con numero de linea
            # -n: mostrar numero de linea
            # -H: mostrar nombre del archivo (forzar cuando es un solo archivo)
            resultado=$(grep -nH "$patron" "$archivo" 2>/dev/null)
            
            if [ -n "$resultado" ]; then
                archivos_con_coincidencias=$((archivos_con_coincidencias + 1))
                archivos_con_coincidencias_lista="$archivos_con_coincidencias_lista $archivo"
                
                echo ""
                echo ">>> Archivo: $archivo"
                echo "----------------------------------------"
                
                # Mostrar cada coincidencia
                while IFS= read -r linea; do
                    if [ -n "$linea" ]; then
                        total_coincidencias=$((total_coincidencias + 1))
                        echo "$linea"
                    fi
                done <<< "$resultado"
            fi
        fi
    done
    
    # Mostrar resumen final
    echo ""
    echo "================================================================"
    echo "RESUMEN DE BUSQUEDA:"
    echo "  Patron buscado: '$patron'"
    echo "  Archivos procesados: $archivos_procesados"
    echo "  Archivos con coincidencias: $archivos_con_coincidencias"
    echo "  Total de coincidencias encontradas: $total_coincidencias"
    
    if [ $archivos_con_coincidencias -gt 0 ]; then
        echo "  Archivos con coincidencias:$archivos_con_coincidencias_lista"
    else
        echo "  No se encontraron coincidencias del patron '$patron'"
    fi
    
    return 0
}

# Funcion alternativa que muestra formato mas detallado
buscar_patron_detallado() {
    local patron="$1"
    
    if [ -z "$patron" ]; then
        echo "ERROR: Patron requerido"
        return 1
    fi
    
    echo "=== BUSQUEDA DETALLADA DE PATRON ==="
    echo "Patron: '$patron'"
    echo "Directorio: $(pwd)"
    echo "Fecha: $(date)"
    echo ""
    
    local encontrado=false
    
    # Buscar en todos los archivos
    for archivo in *; do
        if [ -f "$archivo" ]; then
            # Usar grep con opciones detalladas
            if grep -q "$patron" "$archivo" 2>/dev/null; then
                encontrado=true
                echo "ARCHIVO: $archivo"
                echo "$(printf '%*s' ${#archivo} '' | tr ' ' '=')"
                
                # Mostrar contexto: 1 linea antes y 1 despues
                grep -nC1 --color=never "$patron" "$archivo" 2>/dev/null | while IFS= read -r linea; do
                    echo "  $linea"
                done
                echo ""
            fi
        fi
    done
    
    if [ "$encontrado" = false ]; then
        echo "No se encontraron coincidencias para el patron '$patron'"
    fi
    
    return 0
}

# Verificar parametros del script
if [ $# -eq 0 ]; then
    echo "=== BUSCADOR DE PATRONES CON NUMERO DE LINEA ==="
    echo ""
    echo "Este script busca un patron en todos los archivos del directorio"
    echo "actual y muestra la linea completa junto con su numero de linea."
    echo ""
    echo "Uso: $0 patron [detallado]"
    echo ""
    echo "Ejemplos:"
    echo "  $0 'error'           # Busca la palabra 'error'"
    echo "  $0 'function'        # Busca la palabra 'function'"
    echo "  $0 '^#'              # Busca lineas que empiecen con #"
    echo "  $0 'TODO' detallado  # Busqueda con contexto adicional"
    echo ""
    exit 1
fi

# Obtener patron
patron="$1"
modo="$2"

# Validar patron
if [ -z "$patron" ]; then
    echo "ERROR: El patron no puede estar vacio"
    exit 1
fi

# Verificar que hay archivos en el directorio
if ! ls * >/dev/null 2>&1; then
    echo "ERROR: No hay archivos en el directorio actual"
    exit 1
fi

# Ejecutar segun el modo
if [ "$modo" = "detallado" ]; then
    buscar_patron_detallado "$patron"
else
    buscar_patron_con_lineas "$patron"
fi

# Verificar resultado
if [ $? -eq 0 ]; then
    echo ""
    echo "Busqueda completada exitosamente!"
else
    echo ""
    echo "ERROR: Hubo un problema durante la busqueda"
    exit 1
fi