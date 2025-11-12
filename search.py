#!/usr/bin/env python3
"""
Script para buscar palabras o frases en el índice y obtener sus timestamps.
"""
import argparse
import sqlite3
import csv
from typing import List, Tuple
from unidecode import unidecode


def normalize_text(text: str) -> str:
    """Normaliza texto: minúsculas sin acentos."""
    return unidecode(text).lower().strip()


def seconds_to_hms(seconds: float) -> str:
    """Convierte segundos a formato HH:MM:SS.mmm"""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = seconds % 60
    return f"{hours:02d}:{minutes:02d}:{secs:06.3f}"


def search_word(
    db_path: str,
    term: str,
    min_confidence: float = 0.5,
    first_only: bool = False
) -> List[Tuple[str, float, float, float, str]]:
    """
    Busca una palabra en el índice.
    
    Returns:
        Lista de tuplas (token, t_start, t_end, conf, hh:mm:ss)
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    normalized_term = normalize_text(term)
    
    # Primero buscar como palabra individual
    cursor.execute("""
        SELECT token, t_start, t_end, conf
        FROM word_index
        WHERE token = ? AND conf >= ?
        ORDER BY t_start
    """, (normalized_term, min_confidence))
    
    results = cursor.fetchall()
    
    # Si no hay resultados, buscar en n-gramas
    if not results:
        cursor.execute("""
            SELECT ngram, t_start, t_end, conf
            FROM ngram_index
            WHERE ngram = ? AND conf >= ?
            ORDER BY t_start
        """, (normalized_term, min_confidence))
        
        results = cursor.fetchall()
    
    conn.close()
    
    # Formatear resultados
    formatted_results = []
    for row in results:
        token, t_start, t_end, conf = row
        hms = seconds_to_hms(t_start)
        formatted_results.append((token, t_start, t_end, conf, hms))
        
        if first_only:
            break
    
    return formatted_results


def search_phrase(
    db_path: str,
    phrase: str,
    min_confidence: float = 0.5,
    first_only: bool = False
) -> List[Tuple[str, float, float, float, str]]:
    """
    Busca una frase en el índice de n-gramas.
    
    Returns:
        Lista de tuplas (ngram, t_start, t_end, conf, hh:mm:ss)
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    normalized_phrase = normalize_text(phrase)
    
    cursor.execute("""
        SELECT ngram, t_start, t_end, conf
        FROM ngram_index
        WHERE ngram = ? AND conf >= ?
        ORDER BY t_start
    """, (normalized_phrase, min_confidence))
    
    results = cursor.fetchall()
    conn.close()
    
    # Formatear resultados
    formatted_results = []
    for row in results:
        ngram, t_start, t_end, conf = row
        hms = seconds_to_hms(t_start)
        formatted_results.append((ngram, t_start, t_end, conf, hms))
        
        if first_only:
            break
    
    return formatted_results


def search_flexible(
    db_path: str,
    term: str,
    min_confidence: float = 0.5,
    first_only: bool = False
) -> List[Tuple[str, float, float, float, str]]:
    """
    Búsqueda flexible: detecta si es palabra o frase y busca en ambas tablas.
    """
    normalized_term = normalize_text(term)
    
    # Detectar si es frase (contiene espacios)
    if " " in normalized_term:
        # Buscar en n-gramas
        results = search_phrase(db_path, term, min_confidence, first_only)
    else:
        # Buscar como palabra individual
        results = search_word(db_path, term, min_confidence, first_only)
    
    return results


def export_to_csv(results: List[Tuple], csv_path: str):
    """Exporta resultados a CSV."""
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f, delimiter='|')
        writer.writerow(['token', 't_start', 't_end', 'hh:mm:ss', 'conf'])
        
        for token, t_start, t_end, conf, hms in results:
            writer.writerow([token, f"{t_start:.3f}", f"{t_end:.3f}", hms, f"{conf:.3f}"])
    
    print(f"📄 Resultados exportados a: {csv_path}")


def generate_ffmpeg_commands(results: List[Tuple], video_path: str, margin: int = 8):
    """Genera comandos ffmpeg para extraer clips de cada ocurrencia."""
    print(f"\n🎬 Comandos ffmpeg para extraer clips (margen ±{margin}s):\n")
    
    for i, (token, t_start, t_end, conf, hms) in enumerate(results, 1):
        start_clip = max(0, t_start - margin)
        duration = (t_end - t_start) + (2 * margin)
        
        output_file = f"clip_{i:03d}_{token.replace(' ', '_')[:20]}.mp4"
        
        cmd = (
            f"ffmpeg -i '{video_path}' "
            f"-ss {start_clip:.3f} "
            f"-t {duration:.3f} "
            f"-c copy '{output_file}'"
        )
        
        print(f"# Clip {i} - {hms} ({conf:.2f})")
        print(cmd)
        print()


def main():
    parser = argparse.ArgumentParser(
        description="Busca palabras o frases en el índice y devuelve timestamps"
    )
    parser.add_argument(
        "--db",
        default="index.db",
        help="Ruta a la base de datos SQLite (default: index.db)"
    )
    parser.add_argument(
        "--term",
        required=True,
        help="Palabra o frase a buscar"
    )
    parser.add_argument(
        "--min-conf",
        type=float,
        default=0.5,
        help="Confianza mínima (default: 0.5)"
    )
    parser.add_argument(
        "--first-only",
        action="store_true",
        help="Devolver solo la primera ocurrencia"
    )
    parser.add_argument(
        "--csv",
        help="Exportar resultados a CSV"
    )
    parser.add_argument(
        "--generate-clips",
        metavar="VIDEO_PATH",
        help="Generar comandos ffmpeg para extraer clips"
    )
    parser.add_argument(
        "--clip-margin",
        type=int,
        default=8,
        help="Margen en segundos para los clips (default: 8)"
    )
    
    args = parser.parse_args()
    
    # Verificar que la base de datos existe
    import os
    if not os.path.exists(args.db):
        print(f"❌ Error: No se encuentra la base de datos {args.db}")
        print("   Ejecuta primero run_index.py para crear el índice.")
        return
    
    # Buscar
    print(f"🔍 Buscando: '{args.term}'")
    print(f"   Confianza mínima: {args.min_conf}")
    print(f"   Base de datos: {args.db}\n")
    
    results = search_flexible(
        db_path=args.db,
        term=args.term,
        min_confidence=args.min_conf,
        first_only=args.first_only
    )
    
    if not results:
        print(f"❌ No se encontraron ocurrencias de '{args.term}'")
        print("   Intenta:")
        print(f"   - Reducir la confianza mínima (--min-conf)")
        print(f"   - Verificar la ortografía")
        print(f"   - Buscar variaciones de la palabra")
        return
    
    # Mostrar resultados
    print(f"✅ Se encontraron {len(results)} ocurrencia(s):\n")
    
    for i, (token, t_start, t_end, conf, hms) in enumerate(results, 1):
        print(f"{i:3d}. ⏰ {hms} | 📊 {conf:.2%} | 📝 '{token}'")
        print(f"     ⏱️  {t_start:.3f}s - {t_end:.3f}s")
    
    # Exportar a CSV si se solicitó
    if args.csv:
        print()
        export_to_csv(results, args.csv)
    
    # Generar comandos ffmpeg si se solicitó
    if args.generate_clips:
        generate_ffmpeg_commands(results, args.generate_clips, args.clip_margin)
    
    print(f"\n💡 Tip: Usa VLC o mpv para verificar: mpv '{args.generate_clips or 'video.mp4'}' --start={results[0][1]:.3f}")


if __name__ == "__main__":
    main()

