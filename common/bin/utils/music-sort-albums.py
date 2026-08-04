#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "tinytag>=2.2.1",
# ]
# ///
import os
import re
import shutil

from tinytag import TinyTag

# Definir la ruta base
MUSIC_DIR = os.path.expanduser("~/Music")


def sanitize_folder_name(name):
    """Limpia el nombre del álbum de caracteres no permitidos en directorios."""
    return re.sub(r'[\\/*?:"<>|]', "", name).strip()


def process_music_directory():
    if not os.path.exists(MUSIC_DIR):
        print(f"Error: El directorio {MUSIC_DIR} no existe.")
        return

    # Diccionario para agrupar archivos por nombre de álbum
    # Formato: {'Nombre del Album': ['cancion1.mp3', 'cancion2.mp3']}
    album_groups = {}

    # Extensiones válidas de audio
    valid_extensions = (".mp3", ".m4a", ".flac", ".opus", ".wav", ".ogg")

    print(f"Escaneando archivos de audio en la raíz de {MUSIC_DIR}...")

    # 1. Escanear SOLO los archivos en ~/Music (sin entrar en subdirectorios)
    with os.scandir(MUSIC_DIR) as it:
        for entry in it:
            if entry.is_file() and entry.name.lower().endswith(valid_extensions):
                filepath = entry.path
                try:
                    # Extraer la metadata del archivo
                    tag = TinyTag.get(filepath)
                    album = tag.album

                    # Si tiene un álbum definido, lo añadimos al grupo
                    if album:
                        safe_album_name = sanitize_folder_name(album)
                        if safe_album_name not in album_groups:
                            album_groups[safe_album_name] = []
                        album_groups[safe_album_name].append(entry.name)

                except Exception as e:
                    print(
                        f"Advertencia: No se pudo leer metadata de '{entry.name}': {e}"
                    )

    # 2. Procesar los grupos y mover los archivos si hay > 1 canción
    moved_count = 0
    for album, files in album_groups.items():
        if len(files) > 1:
            album_dir = os.path.join(MUSIC_DIR, album)

            # Crear la carpeta del álbum si no existe aún
            if not os.path.exists(album_dir):
                os.makedirs(album_dir)

            for file in files:
                src_path = os.path.join(MUSIC_DIR, file)
                dest_path = os.path.join(album_dir, file)

                try:
                    shutil.move(src_path, dest_path)
                    print(f"✔ Movido: '{file}' -> '{album}/'")
                    moved_count += 1
                except Exception as e:
                    print(f"Error moviendo '{file}': {e}")

    # Resumen de la operación
    if moved_count == 0:
        print("\nNo se encontraron álbumes con más de una canción para agrupar.")
    else:
        print(
            f"\n¡Organización completada! Se agruparon {moved_count} canciones en carpetas de álbumes."
        )


if __name__ == "__main__":
    process_music_directory()
