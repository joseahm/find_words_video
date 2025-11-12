#!/bin/bash
# Script de instalación automática para Ubuntu/Linux
# Solo ejecuta este script y se instalará todo automáticamente

set -e  # Detener si hay errores

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     🎥 INSTALADOR AUTOMÁTICO - Find Words Video         ║"
echo "║                                                           ║"
echo "║     Para Ubuntu/Linux                                     ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Este script instalará todo automáticamente:"
echo "  ✅ Python 3"
echo "  ✅ ffmpeg"
echo "  ✅ Entorno virtual"
echo "  ✅ Todas las dependencias"
echo ""
read -p "¿Continuar? (s/n): " respuesta

if [ "$respuesta" != "s" ] && [ "$respuesta" != "S" ]; then
    echo "❌ Instalación cancelada"
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Paso 1/4: Actualizando sistema..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo apt update

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Paso 2/4: Instalando Python 3 y ffmpeg..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sudo apt install -y python3 python3-pip python3-venv ffmpeg

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Paso 3/4: Creando entorno virtual..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -d "venv" ]; then
    echo "⚠️  Entorno virtual existente detectado. Eliminando..."
    rm -rf venv
fi
python3 -m venv venv

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 Paso 4/4: Instalando dependencias de Python..."
echo "   (Esto puede tomar 3-5 minutos...)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Verificando instalación..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar Python
PYTHON_VERSION=$(python3 --version)
echo "✅ Python instalado: $PYTHON_VERSION"

# Verificar ffmpeg
FFMPEG_VERSION=$(ffmpeg -version | head -n1)
echo "✅ ffmpeg instalado: $FFMPEG_VERSION"

# Verificar faster-whisper
if python -c "import faster_whisper" 2>/dev/null; then
    echo "✅ faster-whisper instalado correctamente"
else
    echo "❌ Error instalando faster-whisper"
    exit 1
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     ✨ ¡INSTALACIÓN COMPLETADA CON ÉXITO! ✨            ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "🚀 ¿Qué hacer ahora?"
echo ""
echo "1️⃣  Para usar el programa de forma simple:"
echo "   ./start.sh"
echo ""
echo "2️⃣  O manualmente:"
echo "   source venv/bin/activate"
echo "   python run_index.py --video video.mp4 --auto"
echo "   python search.py --term \"palabra a buscar\""
echo ""
echo "📖 Lee README_SIMPLE.md para más información"
echo ""

# Preguntar si quiere probar ahora
read -p "¿Quieres ejecutar el programa ahora? (s/n): " probar

if [ "$probar" = "s" ] || [ "$probar" = "S" ]; then
    echo ""
    echo "🎬 Iniciando start.sh..."
    echo ""
    ./start.sh
fi

echo "👋 ¡Gracias por usar Find Words Video!"

