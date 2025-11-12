#!/bin/bash
# Script de instalación automática para macOS
# Solo ejecuta este script y se instalará todo automáticamente

set -e  # Detener si hay errores

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     🎥 INSTALADOR AUTOMÁTICO - Find Words Video         ║"
echo "║                                                           ║"
echo "║     Para macOS (Mac)                                      ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Este script instalará todo automáticamente:"
echo "  ✅ Homebrew (si no lo tienes)"
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
echo "📦 Paso 1/5: Verificando Homebrew..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v brew &> /dev/null; then
    echo "⚠️  Homebrew no está instalado. Instalando..."
    echo "   (Te pedirá tu contraseña)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configurar Homebrew en el PATH (para Apple Silicon)
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew ya está instalado"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Paso 2/5: Instalando Python 3..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ! command -v python3 &> /dev/null; then
    brew install python@3.11
else
    echo "✅ Python 3 ya está instalado"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Paso 3/5: Instalando ffmpeg..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ! command -v ffmpeg &> /dev/null; then
    brew install ffmpeg
else
    echo "✅ ffmpeg ya está instalado"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Paso 4/5: Creando entorno virtual..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -d "venv" ]; then
    echo "⚠️  Entorno virtual existente detectado. Eliminando..."
    rm -rf venv
fi
python3 -m venv venv

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 Paso 5/5: Instalando dependencias de Python..."
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

