import os
import sys

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio


def get_mime_type(file_path):
    gfile = Gio.File.new_for_path(file_path)
    file_info = gfile.query_info("standard::content-type", 0, None)
    return file_info.get_content_type()


def list_apps(file_path):
    mime_type = get_mime_type(file_path)
    # Buscamos apps compatibles; si no hay, listamos todas como fallback
    apps = Gio.AppInfo.get_all_for_type(mime_type) if mime_type else []
    if not apps:
        apps = Gio.AppInfo.get_all()

    seen = set()
    for app in apps:
        app_id = app.get_id()
        if app_id and app.should_show() and app_id not in seen:
            seen.add(app_id)
            print(f"{app.get_name()} ({app_id})")


def set_default(file_path, app_id):
    mime_type = get_mime_type(file_path)
    if not mime_type:
        print("Error: No se pudo determinar el tipo MIME.")
        sys.exit(1)

    mime_file = os.path.expanduser("~/.config/mimeapps.list")

    if not os.path.exists(mime_file):
        with open(mime_file, "w") as f:
            f.write("[Default Applications]\n")

    with open(mime_file, "r") as f:
        lines = f.readlines()

    # Localizar la sección correcta
    section_idx = -1
    for i, line in enumerate(lines):
        if line.strip() == "[Default Applications]":
            section_idx = i
            break

    if section_idx == -1:
        lines.append("\n[Default Applications]\n")
        section_idx = len(lines) - 1

    # Editar o insertar la línea del MIME type
    mime_prefix = f"{mime_type}="
    replaced = False
    for i in range(section_idx + 1, len(lines)):
        if lines[i].strip().startswith("["):
            break  # Fin de sección
        if lines[i].startswith(mime_prefix):
            lines[i] = f"{mime_prefix}{app_id}\n"
            replaced = True
            break

    if not replaced:
        lines.insert(section_idx + 1, f"{mime_prefix}{app_id}\n")

    with open(mime_file, "w") as f:
        f.writelines(lines)

    print(f"Éxito: {mime_type} ➔ {app_id}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(1)
    if sys.argv[1] == "--list":
        list_apps(sys.argv[2])
    elif sys.argv[1] == "--set":
        set_default(sys.argv[3], sys.argv[2])
