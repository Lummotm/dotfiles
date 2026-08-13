#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "pillow>=12.2.0",
# ]
# ///
"""
Sincronizador avanzado Calibre/KOReader -> Obsidian.
Metadatos reducidos a lo esencial, progreso en % exacto (>1% para "reading") y portadas.
"""

import json
import os
import re
import sqlite3

from PIL import Image

# --- RUTAS REALES ---
LIBRARY_PATH = os.path.expanduser("~/Library/")
PATH_DB = os.path.join(LIBRARY_PATH, "metadata.db")

OBSIDIAN_VAULT = os.path.expanduser(
    "~/Documents/Obsidian/30_areas/01_library/books_vault/"
)
OBSIDIAN_COVERS = os.path.expanduser(
    "~/Documents/Obsidian/99_attachments/covers/book-covers/"
)

os.makedirs(OBSIDIAN_VAULT, exist_ok=True)
os.makedirs(OBSIDIAN_COVERS, exist_ok=True)

valid_ext = ("epub", "azw3", "mobi")
BOOKS_PROCESSED = set()


def get_koreader_data(db_path):
    koreader_data = {}
    if not os.path.exists(db_path):
        print(f"⚠️ No se encontró la base de datos en {db_path}.")
        return koreader_data

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT id FROM custom_columns WHERE label = 'ko_sidecar'")
        col_row = cursor.fetchone()
        if not col_row:
            return koreader_data

        table_name = f"custom_column_{col_row[0]}"
        cursor.execute(
            f"SELECT b.title, c.value FROM books b JOIN {table_name} c ON b.id = c.book WHERE c.value IS NOT NULL AND c.value != ''"
        )

        for title, raw_json in cursor.fetchall():
            safe_title = title.replace("/", "-").replace(":", "-")
            try:
                data = json.loads(raw_json)
            except:
                continue

            raw_progress = 0.0

            # 1. Intentar obtener el progreso
            if "percent_finished" in data:
                raw_progress = float(data.get("percent_finished", 0.0))
            elif "stats" in data and isinstance(data["stats"], dict):
                raw_progress = float(data["stats"].get("performance", 0.0))

            # Convertir decimal (0.45) a entero para Obsidian (45)
            if 0 < raw_progress <= 1.0:
                progress = int(raw_progress * 100)
            elif raw_progress > 1.0:
                progress = min(int(raw_progress), 100)
            else:
                progress = 0

            # Lógica de estados con barrera del 1%
            status = "to read"
            summary_status = str(data.get("summary", {}).get("status", "")).lower()

            if progress >= 100 or summary_status in ["completed", "complete"]:
                progress = 100
                status = "finished"
            elif (
                progress >= 1
            ):  # Exigimos al menos un 1% real para marcarlo como "reading"
                status = "reading"
            else:
                progress = 0  # Si es menos de 1%, lo reseteamos a 0 para mantener limpio el YAML
                status = "to read"

            # 2. Extraer los subrayados/highlights
            notes_dict = {}
            if isinstance(data.get("bookmarks"), dict):
                notes_dict.update(data["bookmarks"])
            if isinstance(data.get("annotations"), dict):
                notes_dict.update(data["annotations"])

            highlights = []
            for bm in notes_dict.values():
                if isinstance(bm, dict) and "text" in bm:
                    texto = bm.get("text", "").strip().replace("\n", " ")
                    if texto:
                        highlights.append(texto)

            koreader_data[safe_title] = {
                "progress": progress,
                "status": status,
                "highlights": highlights,
            }
    except sqlite3.Error as e:
        print(f"❌ Error leyendo DB: {e}")
    finally:
        conn.close()

    return koreader_data


def process_image(image_path, new_path, book_name):
    if not os.path.exists(new_path):
        try:
            with Image.open(image_path) as img:
                img.save(new_path, "WEBP", quality=100, method=6)
            print(f"🖼️ Nueva portada: {book_name}.webp")
        except:
            pass


def find_book_in_vault(book_title):
    for root, dirs, files in os.walk(OBSIDIAN_VAULT):
        if f"{book_title}.md" in files:
            return os.path.join(root, f"{book_title}.md")
    return None


def update_or_create_md(book, author, series, series_index, ko_data):
    md_path = find_book_in_vault(book)

    new_progress = ko_data.get("progress", 0)
    new_status = ko_data.get("status", "to read")
    highlights = ko_data.get("highlights", [])

    # Estructura minimalista
    frontmatter = {
        "author": author,
        "genre": "",
        "type": "book",
        "status": new_status,
        "progress": new_progress,
        "series": series,
        "series_index": series_index,
        "cover": f"{book}.webp",
    }

    body_content = ""

    if md_path:
        with open(md_path, "r", encoding="utf-8") as f:
            content = f.read()

        match = re.match(r"^---\n(.*?)\n---\n(.*)", content, re.DOTALL)
        if match:
            old_yaml = match.group(1)
            rest_of_file = match.group(2)

            for line in old_yaml.split("\n"):
                if ":" in line:
                    k, v = line.split(":", 1)
                    k, v = k.strip(), v.strip()

                    if k in [
                        "book_current_progress",
                        "book_total_length",
                        "ebook_current_progress",
                        "ebook_total_length",
                    ]:
                        continue

                    if k not in ["author", "series", "series_index", "cover"]:
                        if k == "status":
                            if v in ["dropped", "finished"] and new_progress < 100:
                                frontmatter[k] = v
                            elif new_progress >= 1:
                                frontmatter[k] = new_status
                            else:
                                frontmatter[k] = v
                        elif k == "progress":
                            try:
                                old_prog = int(v)
                                frontmatter[k] = max(old_prog, new_progress)
                            except:
                                frontmatter[k] = new_progress
                        else:
                            frontmatter[k] = v

            if "## Highlights" in rest_of_file:
                body_content = rest_of_file.split("## Highlights")[0].strip()
            else:
                body_content = rest_of_file.strip()
    else:
        author_path = os.path.join(OBSIDIAN_VAULT, author)
        os.makedirs(author_path, exist_ok=True)
        md_path = os.path.join(author_path, f"{book}.md")
        print(f"✨ Creando: {book}")

    # Sobreescribir archivo con la nueva estructura
    with open(md_path, "w", encoding="utf-8") as f:
        f.write("---\n")
        for k, v in frontmatter.items():
            v = str(v).replace('"', "")
            f.write(f"{k}: {v}\n")
        f.write("---\n\n")

        if body_content:
            f.write(f"{body_content}\n\n")

        if highlights:
            f.write("## Highlights\n\n")
            f.writelines(f"> {text}\n\n" for text in highlights)


# --- FLUJO PRINCIPAL ---
print("Obteniendo datos de KOReader...")
ALL_KOREADER_DATA = get_koreader_data(PATH_DB)

print("Procesando Calibre...")
for root, dir, files in os.walk(LIBRARY_PATH):
    relative_root = os.path.relpath(root, LIBRARY_PATH)
    if relative_root.startswith(".") or "/" not in relative_root:
        continue

    author = relative_root.split("/")[0].strip()
    book = "Unknown"
    series = "None"
    series_index = 0

    for file in files:
        if "metadata" in file and file.endswith(".opf"):
            with open(os.path.join(root, file), "r", encoding="utf-8") as metadata:
                content = metadata.read()
            t_match = re.search(r"<dc:title>(.*?)</dc:title>", content)
            if t_match:
                book = t_match.group(1).replace("/", "-").replace(":", "-")
            s_match = re.search(r'name="calibre:series" content="(.*?)"', content)
            if s_match:
                series = str(s_match.group(1))
            i_match = re.search(r'name="calibre:series_index" content="(.*?)"', content)
            if i_match:
                series_index = float(i_match.group(1))

    for file in files:
        if "metadata" in file:
            continue

        if "cover" in file:
            old_path = os.path.join(root, file)
            new_path = os.path.join(OBSIDIAN_COVERS, f"{book}.webp")
            process_image(old_path, new_path, book)
            continue

        ext = file.split(".")[-1]
        if ext in valid_ext:
            if book in BOOKS_PROCESSED:
                continue
            BOOKS_PROCESSED.add(book)
            ko_data = ALL_KOREADER_DATA.get(book, {})
            update_or_create_md(book, author, series, series_index, ko_data)

print("✅ Sincronización completada.")
