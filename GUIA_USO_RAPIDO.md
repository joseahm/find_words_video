# 🚀 Guía de Uso Rápido - Auto-Optimización

## ✨ NUEVO: Modo AUTO (Recomendado)

El script ahora **detecta automáticamente** tu hardware y usa la configuración óptima.

---

## 🎯 Uso Más Simple (Recomendado)

```bash
# Activar entorno
source venv/bin/activate

# Indexar con auto-optimización
python run_index.py --video video.mp4 --auto
```

**Eso es todo!** El script detectará:
- ✅ Si tienes GPU NVIDIA → usará CUDA automáticamente
- ✅ Cuántos cores tiene tu CPU → usará el número óptimo de workers
- ✅ El compute_type adecuado para tu hardware

---

## 📊 ¿Qué Detecta Automáticamente?

### Si tienes GPU NVIDIA:
```
🤖 Modo AUTO-OPTIMIZACIÓN activado
   Hardware detectado:
   - CPU: 8 cores
   - GPU: NVIDIA GeForce RTX 3060
   
   Configuración seleccionada:
   - Device: cuda
   - Compute type: float16
   - Workers: 4
   - Modelo: small
```

### Si NO tienes GPU:
```
🤖 Modo AUTO-OPTIMIZACIÓN activado
   Hardware detectado:
   - CPU: 8 cores
   
   Configuración seleccionada:
   - Device: cpu
   - Compute type: int8
   - Workers: 6
   - Modelo: small
```

---

## 🎓 Niveles de Precisión

### 1. Balance (Recomendado) ⚖️
```bash
python run_index.py --video video.mp4 --auto
```
- Modelo: `small`
- Precisión: ⭐⭐⭐⭐ (Muy buena)
- Velocidad: ⚡⚡⚡⚡ (Rápida)

### 2. Máxima Precisión 🎯
```bash
python run_index.py --video video.mp4 --model medium --auto
```
- Modelo: `medium`
- Precisión: ⭐⭐⭐⭐⭐ (Excelente)
- Velocidad: ⚡⚡⚡ (Media)

### 3. Ultra Precisión 🔬
```bash
python run_index.py --video video.mp4 --model large-v3 --auto
```
- Modelo: `large-v3`
- Precisión: ⭐⭐⭐⭐⭐⭐ (Máxima)
- Velocidad: ⚡⚡ (Lenta)
- ⚠️ Requiere GPU o mucho tiempo en CPU

---

## ⏱️ Tiempos Estimados con AUTO

### Con GPU NVIDIA:
| Duración Video | small | medium | large-v3 |
|----------------|-------|--------|----------|
| 30 minutos     | ~1 min | ~2 min | ~4 min |
| 1 hora         | ~2 min | ~4 min | ~8 min |
| 2 horas        | ~5 min | ~8 min | ~15 min |

### Sin GPU (CPU, 8 cores):
| Duración Video | small | medium | large-v3 |
|----------------|-------|--------|----------|
| 30 minutos     | ~5 min | ~10 min | ~20 min |
| 1 hora         | ~10 min | ~20 min | ~40 min |
| 2 horas        | ~20 min | ~40 min | ~80 min |

---

## 🔧 Configuración Manual (Avanzado)

Si quieres controlar manualmente los parámetros:

### Con GPU:
```bash
python run_index.py \
  --video video.mp4 \
  --device cuda \
  --compute-type float16 \
  --workers 4 \
  --model small
```

### Con CPU:
```bash
python run_index.py \
  --video video.mp4 \
  --device cpu \
  --compute-type int8 \
  --workers 6 \
  --model small
```

---

## 💡 Consejos Según Tu Caso

### Video de Podcast/Entrevista (audio claro):
```bash
python run_index.py --video podcast.mp4 --auto
# small es suficiente
```

### Video con Acento/Modismos/Ruido:
```bash
python run_index.py --video video.mp4 --model medium --auto
# medium mejora la precisión
```

### Video Técnico/Académico (terminología compleja):
```bash
python run_index.py --video conferencia.mp4 --model large-v3 --auto
# large-v3 para máxima precisión
```

### Video Muy Largo (3+ horas):
```bash
# Si tienes GPU, usa:
python run_index.py --video largo.mp4 --auto

# Si NO tienes GPU, considera dividir el video:
ffmpeg -i largo.mp4 -t 01:30:00 -c copy parte1.mp4
ffmpeg -i largo.mp4 -ss 01:30:00 -c copy parte2.mp4
```

---

## 🎬 Script Interactivo

Para una experiencia más fácil, usa el script interactivo:

```bash
./start.sh
```

Ahora también usa auto-optimización por defecto.

---

## ❓ FAQ Auto-Optimización

**P: ¿Funciona con laptops con GPU integrada (Intel)?**  
R: No, solo funciona con GPU NVIDIA dedicadas. Usará CPU automáticamente.

**P: ¿Puedo forzar CPU aunque tenga GPU?**  
R: Sí: `python run_index.py --video video.mp4 --device cpu --workers 6`

**P: ¿Y si quiero usar más workers de los recomendados?**  
R: Puedes: `python run_index.py --video video.mp4 --workers 8`

**P: ¿La auto-detección funciona en la primera ejecución?**  
R: Sí, pero si detecta GPU, debes instalar CUDA primero:
```bash
pip install nvidia-cublas-cu12 nvidia-cudnn-cu12
```

---

## 🚦 Resumen Ejecutivo

### Para la MAYORÍA de casos:
```bash
python run_index.py --video video.mp4 --auto
```

### Para MÁXIMA precisión:
```bash
python run_index.py --video video.mp4 --model medium --auto
```

### Para videos MUY largos (3+ horas):
```bash
# Con GPU
python run_index.py --video video.mp4 --model small --auto

# Sin GPU, dividir el video primero
```

---

**¡Listo!** Con `--auto` el script hace todo el trabajo pesado por ti. 🎉

