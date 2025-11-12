# 🎥 Buscador de Palabras en Videos - Guía Para Principiantes

## 📖 ¿Qué hace este programa?

Imagina que tienes un video de **2 horas** y necesitas encontrar en qué minuto se menciona "inteligencia artificial". En vez de ver todo el video, este programa:

1. 🎧 Escucha todo el video automáticamente
2. 📝 Anota cada palabra que se dice y el momento exacto
3. 🔍 Te permite buscar cualquier palabra o frase
4. ⏰ Te dice exactamente en qué minuto aparece (ej: 01:23:45)

**Ejemplo:**
- Video: Podcast de 1 hora
- Buscas: "machine learning"
- Resultado: Aparece en 00:15:23, 00:34:12 y 00:48:55

---

## 💻 ¿Funciona en Mi Computadora?

✅ **Windows** (Windows 10 o superior)  
✅ **Ubuntu/Linux** (cualquier versión reciente)  
✅ **macOS** (macOS 10.15 o superior)

---

# 🚀 INSTALACIÓN AUTOMÁTICA (¡UN SOLO PASO!)

## 🪟 Para WINDOWS:

1. **Descarga** esta carpeta completa a tu computadora
2. **Haz doble clic** en: `instalar_windows.bat`
3. **Sigue las instrucciones** en pantalla (sólo dar "sí" a todo)
4. **¡Listo!** Todo se instala automáticamente

```
💡 El script instalará:
   ✅ Python 3
   ✅ ffmpeg
   ✅ Todas las dependencias
   
   Solo di "sí" cuando te pregunte
```

---

## 🐧 Para UBUNTU/LINUX:

1. **Descarga** esta carpeta completa a tu computadora
2. Abre la **Terminal** en esta carpeta (clic derecho → "Abrir en terminal")
3. **Ejecuta**:
   ```bash
   ./instalar_linux.sh
   ```
4. **Escribe tu contraseña** cuando te la pida
5. **¡Listo!** Todo se instala automáticamente

```
💡 El script instalará:
   ✅ Python 3
   ✅ ffmpeg
   ✅ Todas las dependencias
   
   Solo escribe "s" cuando te pregunte
```

---

## 🍎 Para macOS (Mac):

1. **Descarga** esta carpeta completa a tu computadora
2. Abre la **Terminal** en esta carpeta (clic derecho → "Nuevo terminal en carpeta")
3. **Ejecuta**:
   ```bash
   ./instalar_mac.sh
   ```
4. **Escribe tu contraseña** cuando te la pida
5. **¡Listo!** Todo se instala automáticamente

```
💡 El script instalará:
   ✅ Homebrew (si no lo tienes)
   ✅ Python 3
   ✅ ffmpeg
   ✅ Todas las dependencias
   
   Solo escribe "s" cuando te pregunte
```

---

# 📚 CÓMO USAR EL PROGRAMA

## 🎬 Opción 1: Modo Fácil (Recomendado) - Script Interactivo

### Windows:
1. **Haz doble clic** en: `START.bat`
2. **Sigue las instrucciones** en pantalla
3. ¡Eso es todo! El script te guiará paso a paso

### Linux/Mac:
1. **Abre la Terminal** en esta carpeta
2. **Ejecuta**:
   ```bash
   ./start.sh
   ```
3. **Sigue las instrucciones** en pantalla

💡 **Ambos scripts son interactivos:** Te preguntan qué hacer en cada paso

---

## 🔧 Opción 2: Modo Manual (Para Avanzados)

### Windows:
```
1. Haz doble clic en: INICIAR.bat
   (Esto abre una ventana con el entorno activado)

2. Procesar tu video:
   python run_index.py --video tu_video.mp4 --auto

3. Buscar palabras:
   python search.py --term "lo que busques"
```

### Linux/Mac:
```bash
# Activar entorno
source venv/bin/activate

# Procesar tu video
python run_index.py --video tu_video.mp4 --auto

# Buscar palabras
python search.py --term "lo que busques"
```

---

## ⏱️ ¿Cuánto Demora?

**Procesar el video (solo la primera vez):**
- Video de 30 minutos: ~5-10 minutos
- Video de 1 hora: ~10-20 minutos
- Video de 2 horas: ~20-40 minutos

**Buscar palabras (después):**
- ⚡ Instantáneo (menos de 1 segundo)

---

## 📊 Ejemplo de Resultado

Cuando buscas algo, verás:

```
🔍 Buscando: 'inteligencia artificial'

✅ Se encontraron 3 ocurrencia(s):

  1. ⏰ 00:05:23.450 | 📊 87.34% | 📝 'inteligencia artificial'
  2. ⏰ 00:12:45.780 | 📊 92.15% | 📝 'inteligencia artificial'
  3. ⏰ 01:03:12.220 | 📊 85.67% | 📝 'inteligencia artificial'
```

**Explicación:**
- ⏰ **00:05:23** = Minuto exacto donde aparece
- 📊 **87.34%** = Qué tan seguro está el programa (87% es muy bueno)

---

# 💡 CONSEJOS RÁPIDOS

## Si tu video NO se llama "video.mp4"

Pon el nombre real de tu archivo:

**Windows:**
```
python run_index.py --video "mi_video.mp4" --auto
```

**Linux/Mac:**
```bash
python run_index.py --video "mi_video.mp4" --auto
```

## Si el video está en otra carpeta

**Windows:**
```
python run_index.py --video "C:\Videos\mi_video.mp4" --auto
```

**Linux/Mac:**
```bash
python run_index.py --video "/home/usuario/Videos/mi_video.mp4" --auto
```

## Para buscar frases (no solo palabras)

```bash
# Buscar frase completa
python search.py --term "machine learning"

# Buscar y guardar en CSV
python search.py --term "importante" --csv resultados.csv

# Solo encontrar la primera vez que aparece
python search.py --term "conclusión" --first-only
```

## Si no encuentra una palabra

Prueba sin acentos:
```bash
# En vez de "ética" busca "etica"
python search.py --term "etica"
```

O baja la confianza mínima:
```bash
python search.py --term "palabra" --min-conf 0.3
```

---

# ❓ PREGUNTAS FRECUENTES

## ¿Por qué tarda tanto en procesar?

El programa tiene que **escuchar** todo el video palabra por palabra. Es como si una persona tuviera que transcribir manualmente el video. 

**Pero solo lo haces UNA VEZ.** Después, buscar es instantáneo.

## ¿Cuánto espacio ocupa?

- El programa: ~500 MB (la primera vez)
- Por cada hora de video: ~10-15 MB

## ¿Puedo procesar varios videos?

Sí, crea una base de datos diferente para cada uno:

```bash
python run_index.py --video video1.mp4 --db video1.db --auto
python run_index.py --video video2.mp4 --db video2.db --auto

# Buscar en cada uno
python search.py --db video1.db --term "palabra"
python search.py --db video2.db --term "palabra"
```

## ¿Funciona con cualquier idioma?

Principalmente:
- ✅ Español
- ✅ Inglés
- ✅ Francés
- ✅ Alemán
- ✅ Italiano
- ✅ Portugués

## ¿Qué formato de video acepta?

Casi todos:
- ✅ MP4 (más común)
- ✅ AVI
- ✅ MOV
- ✅ MKV
- ✅ WEBM

## ¿Funciona sin Internet?

**Sí**, una vez instalado. Solo necesitas Internet para:
1. Descargar el instalador (primera vez)
2. El instalador descargará Python y las dependencias

Después funciona 100% sin conexión.

## Mi computadora es lenta, ¿funcionará?

**Sí**, pero tardará más. El programa se adapta automáticamente:
- **Computadora básica:** ~30 min por hora de video
- **Computadora buena:** ~10 min por hora de video
- **Con GPU NVIDIA:** ~2-3 min por hora de video

---

# 🆘 SOLUCIÓN DE PROBLEMAS

## Windows: "No se puede ejecutar instalar_windows.bat"

1. Clic derecho en `instalar_windows.bat`
2. Selecciona "Ejecutar como administrador"

## Linux/Mac: "Permission denied"

```bash
chmod +x instalar_linux.sh
./instalar_linux.sh
```

O para Mac:
```bash
chmod +x instalar_mac.sh
./instalar_mac.sh
```

## Error: "No se encuentra el archivo video.mp4"

El video debe estar en la misma carpeta que el programa, o usa la ruta completa:

```bash
python run_index.py --video "C:\ruta\completa\video.mp4" --auto
```

## No encuentra palabras que SÉ están en el video

1. Busca sin acentos: "informatica" en vez de "informática"
2. Usa `--min-conf 0.3` para encontrar más resultados
3. Si el audio es malo, procesa de nuevo con `--model medium`

## El programa se cierra solo

Tu computadora puede quedarse sin memoria. Cierra otros programas y vuelve a intentar.

---

# 🎉 ¡RESUMEN RÁPIDO!

## 1️⃣ INSTALAR (Una sola vez):

**Windows:** Doble clic en `instalar_windows.bat`  
**Linux:** `./instalar_linux.sh`  
**Mac:** `./instalar_mac.sh`

## 2️⃣ USAR (Modo Fácil):

**Windows:** Doble clic en `START.bat`  
**Linux/Mac:** `./start.sh`

Ambos son **scripts interactivos** que te guían paso a paso.

## 2️⃣ USAR (Modo Manual):

**Windows:** Doble clic en `INICIAR.bat`, luego:
```
python run_index.py --video video.mp4 --auto
python search.py --term "palabra"
```

**Linux/Mac:**
```bash
source venv/bin/activate
python run_index.py --video video.mp4 --auto
python search.py --term "palabra"
```

---

## 📞 ¿Necesitas más ayuda?

- Lee: `LEEME_PRIMERO.txt`
- Para técnicos: `README.md`
- Optimización: `GUIA_USO_RAPIDO.md`

---

**✨ ¡Disfruta encontrando cualquier cosa en tus videos! 🎬**

---

**Versión:** 2.0 (Con instaladores automáticos)  
**Creado para:** Usuarios principiantes  
**Compatibilidad:** Windows 10+, Ubuntu 20.04+, macOS 10.15+
