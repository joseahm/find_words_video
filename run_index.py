#!/usr/bin/env python3
"""
Script para transcribir un video e indexar cada palabra con su timestamp en SQLite.
"""
import argparse
import sqlite3
import subprocess
import os
import multiprocessing
from pathlib import Path
from typing import List, Tuple, Dict
from unidecode import unidecode
from faster_whisper import WhisperModel


def detect_hardware() -> Dict[str, any]:
    """
    Detecta automáticamente el hardware disponible y recomienda configuración óptima.
    
    Returns:
        Dict con: device, compute_type, num_workers, gpu_name (si aplica)
    """
    config = {
        'device': 'cpu',
        'compute_type': 'int8',
        'num_workers': 1,
        'gpu_name': None,
        'cpu_cores': multiprocessing.cpu_count()
    }
    
    # Detectar GPU NVIDIA
    try:
        result = subprocess.run(
            ['nvidia-smi', '--query-gpu=name', '--format=csv,noheader'],
            capture_output=True,
            text=True,
            timeout=2
        )
        if result.returncode == 0 and result.stdout.strip():
            config['device'] = 'cuda'
            config['compute_type'] = 'float16'
            config['num_workers'] = 4  # Óptimo para GPU
            config['gpu_name'] = result.stdout.strip()
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    
    # Si no hay GPU, optimizar para CPU
    if config['device'] == 'cpu':
        cores = config['cpu_cores']
        # Usar cores-2 pero mínimo 1, máximo 8
        optimal_workers = max(1, min(cores - 2, 8))
        config['num_workers'] = optimal_workers
    
    return config


def normalize_text(text: str) -> str:
    """Normaliza texto: minúsculas sin acentos."""
    return unidecode(text).lower().strip()


def extract_audio(video_path: str, audio_path: str = "audio_16k.wav") -> str:
    """Extrae audio del video a 16kHz mono."""
    print(f"📼 Extrayendo audio de {video_path}...")
    
    cmd = [
        "ffmpeg", "-i", video_path,
        "-ac", "1",  # mono
        "-ar", "16000",  # 16kHz
        "-vn",  # sin video
        "-y",  # sobrescribir
        audio_path
    ]
    
    try:
        subprocess.run(cmd, check=True, capture_output=True)
        print(f"✅ Audio extraído: {audio_path}")
        return audio_path
    except subprocess.CalledProcessError as e:
        print(f"❌ Error extrayendo audio: {e.stderr.decode()}")
        raise


def create_database(db_path: str = "index.db") -> sqlite3.Connection:
    """Crea o abre la base de datos SQLite e inicializa las tablas."""
    print(f"🗄️  Creando/abriendo base de datos: {db_path}")
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Tabla de palabras individuales
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS word_index (
            token TEXT NOT NULL,
            t_start REAL NOT NULL,
            t_end REAL NOT NULL,
            conf REAL NOT NULL
        )
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS ix_token 
        ON word_index(token)
    """)
    
    # Tabla de n-gramas (frases)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ngram_index (
            ngram TEXT NOT NULL,
            t_start REAL NOT NULL,
            t_end REAL NOT NULL,
            conf REAL NOT NULL
        )
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS ix_ngram 
        ON ngram_index(ngram)
    """)
    
    conn.commit()
    print("✅ Base de datos lista")
    
    return conn


def generate_ngrams(words: List[Tuple[str, float, float, float]], n: int = 2) -> List[Tuple[str, float, float, float]]:
    """Genera n-gramas a partir de una lista de palabras."""
    ngrams = []
    
    for i in range(len(words) - n + 1):
        tokens = [w[0] for w in words[i:i+n]]
        ngram_text = " ".join(tokens)
        t_start = words[i][1]
        t_end = words[i + n - 1][2]
        # Confianza promedio
        conf_avg = sum(w[3] for w in words[i:i+n]) / n
        
        ngrams.append((ngram_text, t_start, t_end, conf_avg))
    
    return ngrams


def transcribe_and_index(
    audio_path: str,
    db_path: str = "index.db",
    model_size: str = "small",
    device: str = "cpu",
    compute_type: str = "int8",
    batch_size: int = 5000,
    min_confidence: float = 0.0,
    num_workers: int = 4
):
    """Transcribe el audio e indexa palabras y n-gramas en SQLite."""
    print(f"🎙️  Iniciando transcripción con modelo '{model_size}' en {device}...")
    print(f"   💪 Workers: {num_workers} (procesamiento paralelo)")
    
    # Cargar modelo con workers paralelos
    model = WhisperModel(
        model_size,
        device=device,
        compute_type=compute_type,
        num_workers=num_workers,
        cpu_threads=num_workers
    )
    
    # Conectar a la base de datos con optimizaciones
    conn = create_database(db_path)
    cursor = conn.cursor()
    
    # Optimizaciones de SQLite para velocidad
    cursor.execute("PRAGMA synchronous = OFF")
    cursor.execute("PRAGMA journal_mode = MEMORY")
    cursor.execute("PRAGMA cache_size = 10000")
    conn.commit()
    
    # Buffers para inserción por lotes
    word_buffer = []
    ngram_buffer = []
    
    total_words = 0
    total_ngrams = 0
    
    # Transcribir con word timestamps
    segments, info = model.transcribe(
        audio_path,
        word_timestamps=True,
        vad_filter=True,  # filtro de actividad de voz
        language="es"  # ajusta según tu idioma
    )
    
    print(f"📝 Idioma detectado: {info.language} (prob: {info.language_probability:.2f})")
    print("⏳ Procesando segmentos...")
    
    segment_words = []
    
    for segment in segments:
        if not segment.words:
            continue
        
        # Procesar cada palabra del segmento
        for word in segment.words:
            if word.probability < min_confidence:
                continue
            
            token = normalize_text(word.word)
            if not token:
                continue
            
            word_buffer.append((
                token,
                word.start,
                word.end,
                word.probability
            ))
            
            segment_words.append((token, word.start, word.end, word.probability))
            total_words += 1
            
            # Insertar por lotes
            if len(word_buffer) >= batch_size:
                cursor.executemany(
                    "INSERT INTO word_index (token, t_start, t_end, conf) VALUES (?, ?, ?, ?)",
                    word_buffer
                )
                conn.commit()
                print(f"  💾 {total_words:,} palabras indexadas...")
                word_buffer.clear()
        
        # Generar n-gramas del segmento (bigramas y trigramas)
        if len(segment_words) >= 2:
            # Bigramas
            bigrams = generate_ngrams(segment_words, n=2)
            ngram_buffer.extend(bigrams)
            total_ngrams += len(bigrams)
            
            # Trigramas
            if len(segment_words) >= 3:
                trigrams = generate_ngrams(segment_words, n=3)
                ngram_buffer.extend(trigrams)
                total_ngrams += len(trigrams)
        
        # Insertar n-gramas por lotes
        if len(ngram_buffer) >= batch_size:
            cursor.executemany(
                "INSERT INTO ngram_index (ngram, t_start, t_end, conf) VALUES (?, ?, ?, ?)",
                ngram_buffer
            )
            conn.commit()
            ngram_buffer.clear()
        
        segment_words.clear()
    
    # Insertar los restos
    if word_buffer:
        cursor.executemany(
            "INSERT INTO word_index (token, t_start, t_end, conf) VALUES (?, ?, ?, ?)",
            word_buffer
        )
        conn.commit()
    
    if ngram_buffer:
        cursor.executemany(
            "INSERT INTO ngram_index (ngram, t_start, t_end, conf) VALUES (?, ?, ?, ?)",
            ngram_buffer
        )
        conn.commit()
    
    conn.close()
    
    print(f"\n✅ Indexación completa:")
    print(f"   📊 {total_words:,} palabras indexadas")
    print(f"   📊 {total_ngrams:,} n-gramas indexados")
    print(f"   💾 Base de datos: {db_path}")
    
    # Tamaño del archivo
    db_size_mb = os.path.getsize(db_path) / (1024 * 1024)
    print(f"   📦 Tamaño: {db_size_mb:.2f} MB")


def main():
    # Detectar hardware automáticamente
    hw_config = detect_hardware()
    
    parser = argparse.ArgumentParser(
        description="Transcribe video e indexa palabras con timestamps en SQLite",
        epilog=f"Auto-detección: {hw_config['cpu_cores']} cores CPU, "
               f"GPU: {'Sí (' + hw_config['gpu_name'] + ')' if hw_config['gpu_name'] else 'No'}"
    )
    parser.add_argument(
        "--video",
        required=True,
        help="Ruta al archivo de video"
    )
    parser.add_argument(
        "--db",
        default="index.db",
        help="Ruta a la base de datos SQLite (default: index.db)"
    )
    parser.add_argument(
        "--audio",
        default="audio_16k.wav",
        help="Ruta temporal para el audio extraído (default: audio_16k.wav)"
    )
    parser.add_argument(
        "--model",
        default="small",
        choices=["tiny", "base", "small", "medium", "large", "large-v2", "large-v3"],
        help="Tamaño del modelo Whisper (default: small)"
    )
    parser.add_argument(
        "--device",
        default=None,
        choices=["cpu", "cuda", "auto"],
        help=f"Dispositivo de cómputo (default: auto={hw_config['device']})"
    )
    parser.add_argument(
        "--compute-type",
        default=None,
        help=f"Tipo de cómputo para faster-whisper (default: auto={hw_config['compute_type']})"
    )
    parser.add_argument(
        "--min-conf",
        type=float,
        default=0.0,
        help="Confianza mínima para indexar una palabra (default: 0.0)"
    )
    parser.add_argument(
        "--keep-audio",
        action="store_true",
        help="Mantener el archivo de audio después de la indexación"
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=None,
        help=f"Número de workers/threads para procesamiento paralelo (default: auto={hw_config['num_workers']})"
    )
    parser.add_argument(
        "--auto",
        action="store_true",
        help="Usar configuración automática óptima según hardware detectado (recomendado)"
    )
    
    args = parser.parse_args()
    
    # Aplicar configuración automática si se solicita o si no se especificaron parámetros
    if args.auto or (args.device is None and args.workers is None):
        if args.device is None or args.device == "auto":
            args.device = hw_config['device']
        if args.compute_type is None:
            args.compute_type = hw_config['compute_type']
        if args.workers is None:
            args.workers = hw_config['num_workers']
        
        print("🤖 Modo AUTO-OPTIMIZACIÓN activado")
        print(f"   Hardware detectado:")
        print(f"   - CPU: {hw_config['cpu_cores']} cores")
        if hw_config['gpu_name']:
            print(f"   - GPU: {hw_config['gpu_name']}")
        print(f"\n   Configuración seleccionada:")
        print(f"   - Device: {args.device}")
        print(f"   - Compute type: {args.compute_type}")
        print(f"   - Workers: {args.workers}")
        print(f"   - Modelo: {args.model}")
        
        # Advertir si hay GPU disponible pero no está instalado CUDA
        if hw_config['gpu_name'] and args.device == 'cuda':
            print(f"\n   💡 GPU detectada. Si es la primera vez, instala CUDA:")
            print(f"      pip install nvidia-cublas-cu12 nvidia-cudnn-cu12")
        
        print()
    else:
        # Usar valores por defecto si no se especificaron
        if args.device is None:
            args.device = "cpu"
        if args.compute_type is None:
            args.compute_type = "int8" if args.device == "cpu" else "float16"
        if args.workers is None:
            args.workers = 1
    
    # Verificar que el video existe
    if not os.path.exists(args.video):
        print(f"❌ Error: No se encuentra el archivo {args.video}")
        return
    
    try:
        # Extraer audio
        audio_path = extract_audio(args.video, args.audio)
        
        # Transcribir e indexar
        transcribe_and_index(
            audio_path=audio_path,
            db_path=args.db,
            model_size=args.model,
            device=args.device,
            compute_type=args.compute_type,
            min_confidence=args.min_conf,
            num_workers=args.workers
        )
        
        # Limpiar audio temporal
        if not args.keep_audio and os.path.exists(audio_path):
            os.remove(audio_path)
            print(f"🧹 Audio temporal eliminado: {audio_path}")
        
        print("\n✨ ¡Proceso completado! Ahora puedes usar search.py para buscar términos.")
        
    except Exception as e:
        print(f"\n❌ Error durante el proceso: {e}")
        raise


if __name__ == "__main__":
    main()

