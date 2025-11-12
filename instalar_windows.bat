@echo off
REM Script de instalación automática para Windows
REM Solo ejecuta este script y se instalará todo automáticamente

chcp 65001 > nul
setlocal enabledelayedexpansion

echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║     🎥 INSTALADOR AUTOMÁTICO - Find Words Video         ║
echo ║                                                           ║
echo ║     Para Windows 10/11                                    ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo Este script instalará todo automáticamente:
echo   ✅ Python 3 (si no está instalado)
echo   ✅ ffmpeg (descarga portátil)
echo   ✅ Entorno virtual
echo   ✅ Todas las dependencias
echo.
set /p respuesta="¿Continuar? (s/n): "

if /i not "%respuesta%"=="s" (
    echo ❌ Instalación cancelada
    pause
    exit /b 0
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 📦 Paso 1/5: Verificando Python...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python NO está instalado
    echo.
    echo 📥 Descargando Python 3.11...
    echo    Por favor, cuando se abra el instalador:
    echo    ☑️  MARCA LA CASILLA: "Add Python to PATH"
    echo    ☑️  Haz clic en "Install Now"
    echo.
    pause
    
    REM Descargar Python
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe' -OutFile 'python-installer.exe'"
    
    REM Ejecutar instalador
    echo Abriendo instalador de Python...
    start /wait python-installer.exe
    
    REM Limpiar
    del python-installer.exe
    
    echo.
    echo ⚠️  Por favor, CIERRA esta ventana y vuelve a ejecutar este script
    pause
    exit /b 0
) else (
    python --version
    echo ✅ Python ya está instalado
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 📦 Paso 2/5: Verificando ffmpeg...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ffmpeg -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  ffmpeg NO está instalado. Descargando versión portátil...
    
    REM Crear carpeta ffmpeg si no existe
    if not exist "ffmpeg" mkdir ffmpeg
    
    REM Descargar ffmpeg (versión esencial portátil)
    echo Descargando ffmpeg... (puede tomar unos minutos)
    powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg.zip'"
    
    REM Descomprimir
    echo Descomprimiendo...
    powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg_temp' -Force"
    
    REM Mover archivos
    for /d %%i in (ffmpeg_temp\ffmpeg-*) do (
        xcopy /E /I /Y "%%i\bin\*" "ffmpeg\"
    )
    
    REM Limpiar
    del ffmpeg.zip
    rmdir /s /q ffmpeg_temp
    
    echo ✅ ffmpeg descargado en: %CD%\ffmpeg
    echo    (Versión portátil - no necesita instalación)
) else (
    echo ✅ ffmpeg ya está instalado en el sistema
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 🔧 Paso 3/5: Creando entorno virtual...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if exist "venv" (
    echo ⚠️  Entorno virtual existente detectado. Eliminando...
    rmdir /s /q venv
)

python -m venv venv
if %errorlevel% neq 0 (
    echo ❌ Error creando entorno virtual
    pause
    exit /b 1
)

echo ✅ Entorno virtual creado

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 📥 Paso 4/5: Instalando dependencias de Python...
echo    (Esto puede tomar 3-5 minutos...)
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

call venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt

if %errorlevel% neq 0 (
    echo ❌ Error instalando dependencias
    pause
    exit /b 1
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 🔧 Paso 5/5: Creando script de inicio rápido...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REM Crear script de inicio rápido
(
echo @echo off
echo chcp 65001 ^> nul
echo cd /d "%%~dp0"
echo if exist "ffmpeg\ffmpeg.exe" set PATH=%%CD%%\ffmpeg;%%PATH%%
echo call venv\Scripts\activate.bat
echo cls
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║     🎥 Find Words Video - Entorno Activado               ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo 🚀 Comandos disponibles:
echo.
echo    python run_index.py --video video.mp4 --auto
echo    python search.py --term "palabra"
echo.
echo 📖 Escribe 'exit' para salir
echo.
echo.
echo cmd /k
) > INICIAR.bat

echo ✅ Creado: INICIAR.bat (doble clic para abrir el entorno)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ✅ Verificando instalación...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

REM Verificar Python
python --version
echo ✅ Python instalado correctamente

REM Verificar ffmpeg (buscar en carpeta local o sistema)
if exist "ffmpeg\ffmpeg.exe" (
    ffmpeg\ffmpeg.exe -version | findstr "ffmpeg version"
    echo ✅ ffmpeg instalado correctamente (portátil)
) else (
    ffmpeg -version | findstr "ffmpeg version"
    echo ✅ ffmpeg instalado correctamente (sistema)
)

REM Verificar faster-whisper
python -c "import faster_whisper" 2>nul
if %errorlevel% equ 0 (
    echo ✅ faster-whisper instalado correctamente
) else (
    echo ❌ Error instalando faster-whisper
    pause
    exit /b 1
)

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║     ✨ ¡INSTALACIÓN COMPLETADA CON ÉXITO! ✨            ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo 🚀 ¿Qué hacer ahora?
echo.
echo 1️⃣  Modo Fácil (Recomendado):
echo    Doble clic en: START.bat
echo    (Script interactivo que te guía paso a paso)
echo.
echo 2️⃣  Modo Manual:
echo    Doble clic en: INICIAR.bat, luego:
echo    python run_index.py --video video.mp4 --auto
echo    python search.py --term "palabra a buscar"
echo.
echo 📖 Lee README_SIMPLE.md para más información
echo.

pause
echo 👋 ¡Gracias por usar Find Words Video!

