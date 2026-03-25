#!/usr/bin/env python3
from pathlib import Path

import requests
from PIL import Image

# Configuración de Rutas
DOWNLOADS_PATH = Path.home() / "Downloads/Books"
VAULT_PATH = Path.home() / "Documents/Obsidian"
BOOKS_VAULT = VAULT_PATH / "30_areas/01_library/books_vault"
COVERS_PATH = VAULT_PATH / "99_attachments/book-covers"


def normalize_name(name):
    return name.replace("_", " ").title()


def fetch_metadata(title):
    try:
        url = f"https://openlibrary.org/search.json?title={title.replace(' ', '+')}"
        response = requests.get(url, timeout=7).json()
        return response.get("docs", [])[:5]
    except Exception:
        return []


def save_image_as_webp(img_path):
    target_name = f"{normalize_name(img_path.stem)}.webp"
    target_path = COVERS_PATH / target_name
    if not target_path.exists():
        with Image.open(img_path) as img:
            img.save(target_path, "WEBP")
    return target_name


def select_book_metadata(results, default_title):
    data = {"author": "", "pages": 100, "isbn": "", "title": default_title}
    if not results:
        data["author"] = input("Author: ")
        return data

    for i, doc in enumerate(results, 1):
        print(f"[{i}] {doc.get('title')} - {', '.join(doc.get('author_name', []))}")

    choice = input("\nSelect option [0-5]: ")
    if choice.isdigit() and 0 < int(choice) <= len(results):
        res = results[int(choice) - 1]
        data["author"] = ", ".join(res.get("author_name", [""]))
        data["pages"] = res.get("number_of_pages_median", 100)
        data["isbn"] = res.get("isbn", [""])[0]
        data["title"] = res.get("title", default_title)
    else:
        data["author"] = input("Author: ")
    return data


def get_reading_status(suggested_len):
    print("\nStatus: [1] to read, [2] reading, [3] finished, [4] dropped")
    st_choice = input("Choice [1]: ") or "1"
    mapping = {"1": "to read", "2": "reading", "3": "finished", "4": "dropped"}
    status = mapping.get(st_choice, "to read")

    total = input(f"Total length [{suggested_len}]: ") or suggested_len
    current = (
        total
        if status == "finished"
        else (input("Current progress: ") if status != "to read" else 0)
    )

    return status, total, current


def create_obsidian_note(note_path, data, status_info, cover_file):
    status, total, current = status_info
    content = f"""---
author: "{data["author"]}"
genre: 
isbn: "{data["isbn"]}"
type:
  - {data["type"]}
status: {status}
total_length: {total}
current_progress: {current}
cover: "{cover_file}"
aliases: []
id: "{data["title"]}"
---

# {data["title"]}

> [!abstract] **Cover**
> > [!multi-column]
> > 
> > ![[99_attachments/book-covers/{cover_file}|150]]
> >
> > **Status:** `view: status`
> > **Progress:** `view: current_progress` / `view: total_length`
> > **Percentage:** `$= Math.round(({current} / {total}) * 100) || 0` %

---

## Reading Notes
"""
    with open(note_path, "w", encoding="utf-8") as f:
        f.write(content)


def main():
    BOOKS_VAULT.mkdir(parents=True, exist_ok=True)
    COVERS_PATH.mkdir(parents=True, exist_ok=True)

    valid_ext = [".jpg", ".jpeg", ".png", ".webp"]
    files = [f for f in DOWNLOADS_PATH.iterdir() if f.suffix.lower() in valid_ext]

    if not files:
        print("No new covers found.")
        return

    for file_path in files:
        title = normalize_name(file_path.stem)
        note_path = BOOKS_VAULT / f"{title}.md"
        if note_path.exists():
            continue

        print(f"\nProcessing: {title}")
        results = fetch_metadata(title)
        book_data = select_book_metadata(results, title)

        type_choice = input("Type? (1: webnovel, 2: book) [2]: ")
        book_data["type"] = "webnovel" if type_choice == "1" else "book"

        status_info = get_reading_status(book_data["pages"])
        cover_file = save_image_as_webp(file_path)

        create_obsidian_note(note_path, book_data, status_info, cover_file)
        print(f"Done: {title}")


if __name__ == "__main__":
    main()
