#!/bin/bash

echo "=== BUSCADOR DE MÚLTIPLOS DE 7 ==="
echo "Ingresa números hasta encontrar uno que sea múltiplo de 7"
echo "===================================================="

contador=0

while true; do
    contador=$((contador + 1))
    echo -n "Intento #${contador} - Ingresa un número: "
    read input
    
    # Verificar si la entrada es un número válido
    if ! [[ "$input" =~ ^-?[0-9]+$ ]]; then
        echo " Error: '$input' no es un número válido. Intenta de nuevo."
        contador=$((contador - 1))  # No contar intentos inválidos
        continue
    fi
    
    numero=$input
    
    # Verificar si es múltiplo de 7
    if [ $((numero % 7)) -eq 0 ]; then
        echo "  ¡EXCELENTE! El número $numero ES múltiplo de 7"
        echo "   ✓ $numero ÷ 7 = $((numero / 7))"
        echo "   ✓ Encontrado en el intento #${contador}"
        break
    else
        resto=$((numero % 7))
        echo "   El número $numero NO es múltiplo de 7 (resto: $resto)"
        
        # Mostrar el próximo múltiplo como ayuda
        if [ $numero -gt 0 ]; then
            proximo_multiplo=$(( ((numero / 7) + 1) * 7 ))
            anterior_multiplo=$(( (numero / 7) * 7 ))
        else
            proximo_multiplo=$(( (numero / 7) * 7 ))
            anterior_multiplo=$(( ((numero / 7) - 1) * 7 ))
        fi
        
        echo "   💡 Múltiplos cercanos: $anterior_multiplo y $proximo_multiplo"
        echo ""
    fi
done

echo ""
echo "Programa terminado. ¡Gracias por participar!"
echo "   otal de intentos: $contador"