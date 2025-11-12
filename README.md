# 🎥 Find Words Video - Sistema de Búsqueda de Palabras en Videos

Sistema de búsqueda de palabras/frases en videos largos utilizando ASR (Automatic Speech Recognition) con indexación en SQLite.

---

## 📚 ¿Primera Vez Aquí?

**👉 Si NO eres programador/a**, lee primero: **[README_SIMPLE.md](README_SIMPLE.md)**  
(Guía paso a paso para Windows, Ubuntu y macOS con todo bien explicado)

**👨‍💻 Si eres técnico/a**, continúa leyendo este documento.

---

## 📋 Características

- ✅ Transcripción automática con **faster-whisper**
- ✅ Indexación por palabras y n-gramas (bigramas/trigramas)
- ✅ Normalización de texto (sin acentos, minúsculas)
- ✅ Búsqueda instantánea con timestamps precisos
- ✅ Exportación a CSV
- ✅ Generación de comandos ffmpeg para clips
- ✅ Procesamiento en streaming (bajo consumo de RAM)
- ✅ Filtro VAD (Voice Activity Detection) para reducir ruido

## 🔧 Instalación

### 1. Instalar ffmpeg (si no lo tienes)

```bash
sudo apt-get update
sudo apt-get install ffmpeg
```

### 2. Crear entorno virtual e instalar dependencias

```bash
# Crear entorno virtual
python3 -m venv venv

# Activar entorno virtual
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt
```

## 🚀 Uso

### Paso 1: Indexar un video

#### Modo AUTO (Recomendado) - Detecta hardware automáticamente:

```bash
python run_index.py --video video.mp4 --auto
```

El sistema detectará:
- ✅ GPU NVIDIA (si está disponible)
- ✅ Número de CPU cores
- ✅ Configuración óptima de workers

#### Modo Manual:

```bash
python run_index.py --video video.mp4
```

**Opciones avanzadas:**

```bash
# Con auto-optimización y modelo medium
python run_index.py \
  --video video.mp4 \
  --model medium \
  --auto

# Manual completo
python run_index.py \
  --video video.mp4 \
  --db index.db \
  --model medium \
  --device cpu \
  --workers 6 \
  --min-conf 0.5 \
  --keep-audio
```

**Parámetros:**
- `--video`: Ruta al video (requerido)
- `--auto`: 🆕 Detecta hardware y optimiza automáticamente (recomendado)
- `--db`: Base de datos SQLite (default: `index.db`)
- `--audio`: Ruta temporal para audio (default: `audio_16k.wav`)
- `--model`: Tamaño del modelo Whisper (tiny, base, **small**, medium, large, large-v3)
  - `small`: Rápido, buena precisión (recomendado para CPU)
  - `medium`: Mejor precisión, más lento
  - `large-v3`: Máxima precisión (recomendado para GPU)
- `--device`: `cpu`, `cuda` o `auto` (default: auto)
- `--compute-type`: `int8` (CPU), `float16` (GPU) o auto (default: auto)
- `--workers`: Número de threads paralelos (default: auto según CPU cores)
- `--min-conf`: Confianza mínima para indexar (0.0-1.0)
- `--keep-audio`: Mantener archivo de audio temporal

**Tiempos estimados:**
- Video de 1 hora con modelo `small` en CPU: ~10-15 minutos
- Video de 1 hora con modelo `medium` en GPU: ~5-8 minutos

### Paso 2: Buscar palabras o frases

```bash
# Buscar una palabra
python search.py --term "hola"

# Buscar una frase
python search.py --term "hola mundo"

# Solo primera ocurrencia
python search.py --term "importante" --first-only

# Ajustar confianza mínima
python search.py --term "palabra" --min-conf 0.6

# Exportar a CSV
python search.py --term "tema" --csv resultados.csv

# Generar comandos para extraer clips
python search.py --term "conclusión" --generate-clips video.mp4
```

**Parámetros:**
- `--term`: Palabra o frase a buscar (requerido)
- `--db`: Base de datos SQLite (default: `index.db`)
- `--min-conf`: Confianza mínima (default: 0.5)
- `--first-only`: Solo devolver primera ocurrencia
- `--csv`: Exportar resultados a CSV
- `--generate-clips`: Generar comandos ffmpeg para clips
- `--clip-margin`: Margen en segundos para clips (default: 8)

## 📊 Ejemplo de salida

```
🔍 Buscando: 'machine learning'
   Confianza mínima: 0.5
   Base de datos: index.db

✅ Se encontraron 3 ocurrencia(s):

  1. ⏰ 00:05:23.450 | 📊 87.34% | 📝 'machine learning'
     ⏱️  323.450s - 324.120s
  2. ⏰ 00:12:45.780 | 📊 92.15% | 📝 'machine learning'
     ⏱️  765.780s - 766.340s
  3. ⏰ 01:03:12.220 | 📊 85.67% | 📝 'machine learning'
     ⏱️  3792.220s - 3792.890s

💡 Tip: Usa VLC o mpv para verificar: mpv 'video.mp4' --start=323.450
```

## 📁 Estructura del proyecto

```
Find_Words_Video/
├── venv/                    # Entorno virtual
├── video.mp4                # Tu video
├── requirements.txt         # Dependencias
├── run_index.py            # Script de indexación (con auto-detección)
├── search.py               # Script de búsqueda
├── ejemplo_uso.sh          # Script interactivo
├── detectar_hardware.sh    # Detecta GPU/CPU
├── index.db                # Base de datos generada
├── README.md               # Este archivo (técnico)
├── README_SIMPLE.md        # 🆕 Guía para principiantes
└── GUIA_USO_RAPIDO.md      # Guía de auto-optimización
```

## 🎯 Casos de uso

### 1. Encontrar todas las menciones de un tema

```bash
python search.py --term "inteligencia artificial" --csv menciones_ia.csv
```

### 2. Saltar a una sección específica

```bash
python search.py --term "conclusión" --first-only
# Luego abrir el video en ese timestamp
```

### 3. Crear clips de momentos clave

```bash
python search.py --term "importante" --generate-clips video.mp4 > extract_clips.sh
bash extract_clips.sh
```

### 4. Análisis de contenido

```bash
# Exportar todas las menciones a CSV para análisis
python search.py --term "producto" --csv producto.csv
python search.py --term "precio" --csv precio.csv
python search.py --term "cliente" --csv cliente.csv
```

## 🔍 Normalización de texto

El sistema normaliza automáticamente:
- **Acentos**: "anótalo" → "anotalo"
- **Mayúsculas**: "HOLA" → "hola"
- **Espacios**: " palabra " → "palabra"

Esto permite buscar sin preocuparse por acentos o mayúsculas.

## ⚙️ Configuración recomendada

### 🆕 Auto-Optimización (Más Fácil)

```bash
# Detecta automáticamente GPU/CPU y optimiza
python run_index.py --video video.mp4 --auto

# Con modelo medium para mayor precisión
python run_index.py --video video.mp4 --model medium --auto
```

### Configuración Manual

#### Para CPU (sin GPU)
```bash
python run_index.py --video video.mp4 --model small --device cpu --workers 6
```

#### Para GPU (NVIDIA con CUDA)
```bash
python run_index.py --video video.mp4 --model large-v3 --device cuda --compute-type float16
```

#### Para alta precisión
```bash
python run_index.py --video video.mp4 --model medium --min-conf 0.6 --auto
```

#### Para máxima cobertura
```bash
python run_index.py --video video.mp4 --model small --min-conf 0.3 --auto
```

## 🐛 Solución de problemas

### "No se encuentran resultados"
- Reduce `--min-conf` (ej: `0.3` o `0.4`)
- Verifica la ortografía
- Prueba sin acentos
- Usa un modelo más grande (`medium` o `large-v3`)

### "Audio con mucho ruido"
El filtro VAD está activado por defecto, pero puedes ajustar:
- Aumentar `--min-conf` a `0.6` o `0.7`
- Usar un modelo más grande

### "Frases no encontradas"
- El sistema indexa bigramas (2 palabras) y trigramas (3 palabras)
- Para frases más largas, busca subsecciones
- Ejemplo: en vez de "hola mundo cómo estás", busca "hola mundo" o "mundo cómo"

### "Proceso muy lento"
- Usa modelo `small` en vez de `medium` o `large`
- Si tienes GPU NVIDIA, usa `--device cuda`
- El procesamiento es normal: ~15 min por hora de video en CPU

## 📈 Rendimiento

**Video de 1 hora típico:**
- Palabras indexadas: ~6,000-10,000
- N-gramas indexados: ~12,000-20,000
- Tamaño base de datos: ~10-15 MB
- Tiempo de búsqueda: <100ms

## 🎓 Tecnologías utilizadas

- **faster-whisper**: Motor de transcripción ASR
- **SQLite**: Base de datos para indexación
- **ffmpeg**: Extracción de audio
- **unidecode**: Normalización de texto

## 📝 Notas

- La primera ejecución descargará el modelo de Whisper (~150-3000 MB según tamaño)
- Los modelos se cachean en `~/.cache/huggingface/hub/`
- El idioma se detecta automáticamente (configurable en el código)
- Para múltiples videos, crea una DB por video o agrega una columna `video_id`

## 🚦 Próximos pasos

1. Indexa tu primer video: `python run_index.py --video video.mp4`
2. Busca una palabra: `python search.py --term "palabra"`
3. Experimenta con diferentes configuraciones
4. Integra en tus flujos de trabajo

---

**¿Preguntas o problemas?** Revisa la documentación de [faster-whisper](https://github.com/guillaumekln/faster-whisper) y [ffmpeg](https://ffmpeg.org/documentation.html).

