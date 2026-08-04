from pathlib import Path

from PIL import Image

VAULT_PATH = Path("~/Documents/Obsidian/").expanduser()
ATTACHMENTS_FOLDER = VAULT_PATH / "99_attachments"
VALID_EXT = {".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tiff"}


def run_smart_optimizer():
    existing_images = [
        file
        for file in ATTACHMENTS_FOLDER.rglob("*")
        if file.is_file() and file.suffix.lower() in VALID_EXT
    ]

    images_to_process = []
    for old_path in existing_images:
        new_filename = f"{old_path.stem.replace("'", '_')}.webp"
        if old_path.name != new_filename:
            images_to_process.append(old_path)

    # Salir inmediatamente si no hay imágenes nuevas que procesar
    if not images_to_process:
        return

    replacements = {}
    for old_path in images_to_process:
        filename = old_path.name
        new_filename = f"{old_path.stem.replace("'", '_')}.webp"
        new_path = old_path.parent / new_filename

        try:
            with Image.open(old_path) as img:
                img.save(new_path, "WEBP", quality=75, method=6)

            if new_path.exists():
                old_path.unlink()
                replacements[filename] = new_filename
                print(f"Compressed: {filename}")
        except Exception as e:
            print(f"Error {filename}: {e}")

    # Salir si fallaron las conversiones y no hay reemplazos que aplicar
    if not replacements:
        return

    notes_to_update = []

    for root, dirs, files in VAULT_PATH.walk():
        dirs[:] = [d for d in dirs if not d.startswith(".")]

        for file in files:
            if not file.endswith(".md"):
                continue

            md_path = root / file
            try:
                with open(md_path, "r", encoding="utf-8") as f:
                    content = f.read()

                # Filtro rápido: actualizar solo si el nombre viejo está en la nota
                if any(old_name in content for old_name in replacements.keys()):
                    original_content = content
                    for old_name, new_name in replacements.items():
                        if old_name in content:
                            content = content.replace(old_name, new_name)

                    if content != original_content:
                        with open(md_path, "w", encoding="utf-8") as f:
                            f.write(content)
                        notes_to_update.append(md_path)
            except Exception:
                continue

    print(
        f"Actualizadas {len(notes_to_update)} notas con las nuevas rutas de imágenes."
    )


run_smart_optimizer()
