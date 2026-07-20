#!/usr/bin/env python3
import glob
import os
import re
import sys

# Definir las rutas base
MUSIC_DIR = os.path.expanduser("~/Music")
PLAYLIST_DIR = os.path.join(MUSIC_DIR, "0-playlists")

# Verificamos si se pasó el argumento --silent
SILENT = "--silent" in sys.argv


def log(mensaje):
    """Imprime el mensaje en consola solo si no estamos en modo silencioso."""
    if not SILENT:
        print(mensaje)


def build_file_index():
    log("Indexando archivos de audio reales en ~/Music...")
    index = {}

    for root, _, files in os.walk(MUSIC_DIR):
        if root.startswith(PLAYLIST_DIR):
            continue

        for file in files:
            if file.endswith((".mp3", ".m4a", ".flac", ".opus", ".wav", ".ogg")):
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, MUSIC_DIR)
                index[file] = rel_path

    return index


def get_actual_path(line, file_index):
    line = line.strip()

    if not line or line.startswith("#"):
        return None

    for prefix in ["Music/", "$HOME/Music/", "~/Music/"]:
        if line.startswith(prefix):
            line = line[len(prefix) :]
            break

    filename = os.path.basename(line)

    if filename in file_index:
        return file_index[filename]

    return line


def process_directory():
    file_index = build_file_index()

    log(f"\nProcesando playlists en: {PLAYLIST_DIR}")
    m3u_files = glob.glob(os.path.join(PLAYLIST_DIR, "*.m3u"))
    groups = {}

    for filepath in m3u_files:
        filename = os.path.basename(filepath)
        match = re.match(r"^(.*?)(?:\s*\(\d+\))?\.m3u$", filename)

        if match:
            basename = match.group(1).strip()
        else:
            basename = filename.replace(".m3u", "").strip()

        if basename not in groups:
            groups[basename] = []
        groups[basename].append(filepath)

    for basename, files in groups.items():
        seen_tracks = set()
        merged_tracks = []

        for filepath in files:
            with open(filepath, "r", encoding="utf-8") as f:
                for line in f:
                    actual_path = get_actual_path(line, file_index)
                    if actual_path and actual_path not in seen_tracks:
                        seen_tracks.add(actual_path)
                        merged_tracks.append(actual_path)

        output_file = os.path.join(PLAYLIST_DIR, f"{basename}.m3u")

        with open(output_file, "w", encoding="utf-8") as f:
            for track in merged_tracks:
                f.write(f"{track}\n")

        for filepath in files:
            if os.path.abspath(filepath) != os.path.abspath(output_file):
                os.remove(filepath)

        log(
            f"✔ '{basename}.m3u' refactorizado y limpiado: {len(merged_tracks)} pistas."
        )


if __name__ == "__main__":
    if not os.path.exists(PLAYLIST_DIR):
        log(f"Error: El directorio {PLAYLIST_DIR} no existe.")
    else:
        process_directory()
