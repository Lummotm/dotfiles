# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "pillow>=12.2.0",
# ]
# ///
"""
This scripts attempts to parse all books on Library, assuming it follows the Calibre folder structure.
Then creates a .md file and a cover path with the assumed structure for my book base on obsidian on ~/temp/book-base/
"""

import os
import re
import shutil

from PIL import Image

TEMP_PATH = os.path.expanduser("~/temp/book-base/")
LIBRARY_PATH = os.path.expanduser("~/Library/")

if os.path.exists(TEMP_PATH):
    shutil.rmtree(TEMP_PATH)

os.makedirs(TEMP_PATH + "covers/", exist_ok=True)
os.makedirs(TEMP_PATH + "files/", exist_ok=True)

BOOKS = set()
valid_ext = ("epub", "azw3", "mobi")


def process_image(image_path, new_path):
    os.makedirs(os.path.dirname(new_path), exist_ok=True)
    try:
        with Image.open(image_path) as img:
            img.save(new_path, "WEBP", quality=100, method=6)
    except Exception as e:
        print(f"Error {image_path}: {e}")


def create_md(book, author, series: str = "None", series_index: float = 0):
    author_path = TEMP_PATH + "files/" + author + "/"
    os.makedirs(author_path, exist_ok=True)

    md_file_path = author_path + book + ".md"
    print(md_file_path)
    with open(md_file_path, "w", encoding="utf-8") as f:
        f.write(
            f"---\n"
            f"author: {author}\n"
            f"genre: \n"
            f"type: book\n"
            f"status: to read\n"
            f"book_current_progress: 0\n"
            f"book_total_length: 100\n"
            f"ebook_current_progress: 0\n"
            f"ebook_total_length: 100\n"
            f"series: {series}\n"
            f"series_index: {series_index}\n"
            f"cover: {book}.webp \n"
            f"---\n\n"
        )


for root, dir, files in os.walk(LIBRARY_PATH):
    relative_root = os.path.relpath(root, LIBRARY_PATH)
    if relative_root.startswith("."):
        continue

    if "/" not in relative_root:
        continue

    author = relative_root.split("/")[0].strip()

    book = "Unknown"
    series = "None"
    series_index = 0
    for file in files:
        if "metadata" in file:
            with open(os.path.join(root, file), "r", encoding="utf-8") as metadata:
                content = metadata.read()

            # Buscando el título
            t_match = re.search(r"<dc:title>(.*?)</dc:title>", content)
            if t_match:
                # Pick  first match of the regex, replace special chars
                book = t_match.group(1).replace("/", "-").replace(":", "-")

            # Busqueda de la series
            s_match = re.search(r'name="calibre:series" content="(.*?)"', content)
            if s_match:
                series = str(s_match.group(1))

            # Buscamos el índice
            i_match = re.search(r'name="calibre:series_index" content="(.*?)"', content)
            if i_match:
                series_index = float(i_match.group(1))

    for file in files:
        if "metadata" in file:
            continue
        if "cover" in file:
            old_path = os.path.join(root, file)
            new_path = TEMP_PATH + "covers/" + author + "/" + book + ".webp"
            if not os.path.exists(new_path):
                process_image(old_path, new_path)
            continue

        ext = file.split(".")[-1]
        if ext in valid_ext:
            if book in BOOKS:
                continue
            BOOKS.add(book)
            create_md(book, author, series, series_index)
