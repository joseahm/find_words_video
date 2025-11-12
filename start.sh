#!/bin/bash
# Script de ejemplo para usar el sistema de búsqueda de palabras en videos

echo "======================================"
echo "📹 Find Words Video - Ejemplo de Uso"
echo "======================================"
echo ""

# Activar entorno virtual
source venv/bin/activate

# Verificar si existe video.mp4
if [ ! -f "video.mp4" ]; then
    echo "⚠️  No se encontró video.mp4"
    echo "   Coloca tu video en esta carpeta con el nombre 'video.mp4'"
    echo "   o modifica este script para usar otro archivo."
    exit 1
fi

# Verificar si ya existe el índice
if [ -f "index.db" ]; then
    echo "✅ Base de datos existente encontrada: index.db"
    echo ""
    echo "Opciones:"
    echo "1. Buscar en el índice existente"
    echo "2. Re-indexar el video (esto tomará tiempo)"
    echo ""
    read -p "Selecciona una opción (1/2): " opcion
    
    if [ "$opcion" = "2" ]; then
        echo ""
        echo "🔄 Re-indexando video..."
        rm -f index.db
        python run_index.py --video video.mp4 --model small --auto
    fi
else
    echo "📝 No se encontró índice existente."
    echo "🎙️  Iniciando transcripción e indexación..."
    echo "   (Detectando hardware y optimizando automáticamente...)"
    echo ""
    
    python run_index.py --video video.mp4 --model small --auto
    
    if [ $? -ne 0 ]; then
        echo "❌ Error al indexar el video"
        exit 1
    fi
fi

echo ""
echo "======================================"
echo "🔍 Modo de Búsqueda"
echo "======================================"
echo ""
echo "Ejemplos de búsquedas:"
echo "  - Palabra simple: 'hola'"
echo "  - Frase: 'machine learning'"
echo "  - Palabra con acentos: 'informática' (funciona sin acentos también)"
echo ""

# Loop de búsqueda
while true; do
    echo ""
    read -p "🔎 Buscar término (o 'salir' para terminar): " termino
    
    if [ "$termino" = "salir" ] || [ "$termino" = "exit" ] || [ "$termino" = "q" ]; then
        echo "👋 ¡Hasta luego!"
        break
    fi
    
    if [ -z "$termino" ]; then
        continue
    fi
    
    echo ""
    python search.py --term "$termino" --min-conf 0.5
    
    echo ""
    read -p "¿Exportar a CSV? (s/n): " exportar
    
    if [ "$exportar" = "s" ] || [ "$exportar" = "S" ]; then
        archivo_csv="${termino// /_}_resultados.csv"
        python search.py --term "$termino" --min-conf 0.5 --csv "$archivo_csv"
    fi
done

deactivate

