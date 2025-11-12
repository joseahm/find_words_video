@echo off
REM Script interactivo para Windows - equivalente a start.sh
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ======================================
echo 📹 Find Words Video - Modo Interactivo
echo ======================================
echo.

REM Cambiar al directorio del script
cd /d "%~dp0"

REM Configurar ffmpeg si existe localmente
if exist "ffmpeg\ffmpeg.exe" set PATH=%CD%\ffmpeg;%PATH%

REM Activar entorno virtual
if not exist "venv" (
    echo ❌ Error: Entorno virtual no encontrado
    echo    Ejecuta primero: instalar_windows.bat
    echo.
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

REM Verificar si existe video.mp4
if not exist "video.mp4" (
    echo ⚠️  No se encontró video.mp4
    echo    Coloca tu video en esta carpeta con el nombre 'video.mp4'
    echo    o recuerda el nombre de tu archivo para el siguiente paso.
    echo.
)

REM Verificar si ya existe el índice
if exist "index.db" (
    echo ✅ Base de datos existente encontrada: index.db
    echo.
    echo Opciones:
    echo 1. Buscar en el índice existente
    echo 2. Re-indexar el video ^(esto tomará tiempo^)
    echo.
    set /p opcion="Selecciona una opción (1/2): "
    
    if "!opcion!"=="2" (
        echo.
        echo 🔄 Re-indexando video...
        del /f index.db
        python run_index.py --video video.mp4 --model small --auto
    )
) else (
    echo 📝 No se encontró índice existente.
    echo 🎙️  Iniciando transcripción e indexación...
    echo    ^(Detectando hardware y optimizando automáticamente...^)
    echo.
    
    python run_index.py --video video.mp4 --model small --auto
    
    if !errorlevel! neq 0 (
        echo ❌ Error al indexar el video
        pause
        exit /b 1
    )
)

echo.
echo ======================================
echo 🔍 Modo de Búsqueda
echo ======================================
echo.
echo Ejemplos de búsquedas:
echo   - Palabra simple: 'hola'
echo   - Frase: 'machine learning'
echo   - Palabra con acentos: 'informática' ^(funciona sin acentos también^)
echo.

REM Loop de búsqueda
:busqueda_loop
    echo.
    set /p termino="🔎 Buscar término (o 'salir' para terminar): "
    
    if "!termino!"=="salir" goto fin
    if "!termino!"=="exit" goto fin
    if "!termino!"=="q" goto fin
    
    if "!termino!"=="" goto busqueda_loop
    
    echo.
    python search.py --term "!termino!" --min-conf 0.5
    
    echo.
    set /p exportar="¿Exportar a CSV? (s/n): "
    
    if /i "!exportar!"=="s" (
        set archivo_csv=!termino:~0,20!_resultados.csv
        set archivo_csv=!archivo_csv: =_!
        python search.py --term "!termino!" --min-conf 0.5 --csv "!archivo_csv!"
    )
    
    goto busqueda_loop

:fin
echo.
echo 👋 ¡Hasta luego!
pause

