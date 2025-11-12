#!/bin/bash
# Script para detectar hardware y recomendar la mejor configuración

echo "======================================"
echo "🔍 Detectando Hardware Disponible"
echo "======================================"
echo ""

# Detectar GPU NVIDIA
if command -v nvidia-smi &> /dev/null; then
    echo "✅ GPU NVIDIA detectada:"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader | head -n1
    HAS_GPU=true
    echo ""
else
    echo "❌ No se detectó GPU NVIDIA"
    HAS_GPU=false
    echo ""
fi

# Detectar número de cores
CORES=$(nproc)
echo "✅ CPU: $CORES cores detectados"
echo ""

# Detectar memoria RAM
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
echo "✅ RAM: ${RAM_GB}GB disponibles"
echo ""

echo "======================================"
echo "💡 Recomendación de Configuración"
echo "======================================"
echo ""

if [ "$HAS_GPU" = true ]; then
    echo "🚀 CONFIGURACIÓN ÓPTIMA (con GPU):"
    echo ""
    echo "   python run_index.py \\"
    echo "     --video video.mp4 \\"
    echo "     --device cuda \\"
    echo "     --compute-type float16 \\"
    echo "     --workers 4"
    echo ""
    echo "⚡ Velocidad estimada: 5-10x más rápido que CPU"
    echo "⏱️  Tiempo para 1 hora de video: ~2-3 minutos"
    echo ""
    echo "📝 Nota: La primera vez instalará drivers CUDA:"
    echo "   pip install nvidia-cublas-cu12 nvidia-cudnn-cu12"
    echo ""
else
    # Calcular workers recomendados (dejar 2 cores libres)
    RECOMMENDED_WORKERS=$((CORES - 2))
    [ $RECOMMENDED_WORKERS -lt 1 ] && RECOMMENDED_WORKERS=1
    [ $RECOMMENDED_WORKERS -gt 8 ] && RECOMMENDED_WORKERS=8
    
    echo "💪 CONFIGURACIÓN ÓPTIMA (solo CPU):"
    echo ""
    echo "   python run_index.py \\"
    echo "     --video video.mp4 \\"
    echo "     --workers $RECOMMENDED_WORKERS"
    echo ""
    echo "⚡ Velocidad estimada: 1.3-1.5x más rápido que modo básico"
    echo "⏱️  Tiempo para 1 hora de video: ~10-12 minutos"
    echo ""
fi

echo "======================================"
echo "📊 Otras Opciones"
echo "======================================"
echo ""

if [ "$HAS_GPU" = true ]; then
    echo "🎯 Para MÁXIMA precisión (con GPU):"
    echo "   python run_index.py --video video.mp4 --model medium --device cuda --compute-type float16"
    echo ""
fi

echo "🎯 Para MÁXIMA precisión (CPU):"
PRECISION_WORKERS=$((CORES / 2))
[ $PRECISION_WORKERS -lt 1 ] && PRECISION_WORKERS=1
echo "   python run_index.py --video video.mp4 --model medium --workers $PRECISION_WORKERS"
echo ""

echo "⚡ Para velocidad (menor precisión):"
echo "   python run_index.py --video video.mp4 --model tiny --workers $CORES"
echo ""

echo "======================================"
echo "💡 Consejos"
echo "======================================"
echo ""

if [ "$HAS_GPU" = false ]; then
    echo "💰 Considera usar Google Colab (gratis) con GPU para procesar videos largos:"
    echo "   https://colab.research.google.com/"
    echo ""
fi

if [ $RAM_GB -lt 4 ]; then
    echo "⚠️  RAM baja detectada. Reduce workers si el sistema se congela:"
    echo "   python run_index.py --video video.mp4 --workers 1"
    echo ""
fi

echo "📖 Lee COMO_ACELERAR.md para más detalles"
echo ""

