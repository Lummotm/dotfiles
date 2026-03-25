import os
import sys

# =====================================================================
# NOTA DE RENDIMIENTO (Benchmarks con 5000 notas):
# Se utiliza `os.walk` de forma deliberada en lugar de `pathlib` para
# maximizar la velocidad, ya que este script alimenta a rofi/fzf.
#
# Intentos previos con pathlib:
# 1. Path.rglob("*"): ~190ms -> Muy lento debido a la creación masiva
#    de objetos WindowsPath/PosixPath por cada archivo encontrado.
# 2. Path.walk(): ~36ms / ~37ms -> Rápido, pero sigue instanciando objetos Path
#    para la variable 'root' en cada iteración.
# 3. os.walk(): ~18ms (búsqueda) / ~39ms (listado) -> El ganador
#    indiscutible al trabajar exclusivamente con strings crudos en C.
# =====================================================================

ICON = ""
NOTES_DIR = sys.argv[1]

if len(sys.argv) < 2:
    NOTE = ""
NOTE = sys.argv[2]

VALID_EXT = {".md", ".base"}
FIXED_SPACES = " " * 4

notes_dictionary = {}
current = 0

if NOTE == "":
    # Estamos listando
    for root, _, files in os.walk(NOTES_DIR):
        if any(dir.startswith(".") for dir in root):
            continue

        # Obtenemos ruta relativa respecto de la de las notas
        relative_path = os.path.relpath(root, NOTES_DIR)

        # Si el origen es root, lo indicamos
        if relative_path == ".":
            relative_path = "root"

        for file in files:
            if file.startswith("."):
                continue
            if not any(file.endswith(ext) for ext in VALID_EXT):
                continue

            notes_dictionary[file] = [
                relative_path
            ]  # Asociamos un archivo a su path relativa no hace falta mas de una direccion por archivo

    # Mido archivo de maxima longitud
    for file in notes_dictionary:
        if len(file) > current:
            current = len(file)

    # Definimos la llave de ordenación para anclar los TODOs arriba
    def sort_notes(filename):
        if filename == "00_todo.md":
            return (0, filename)
        if filename == "01_todo_inbox.md":
            return (1, filename)

        # El resto de archivos van después, ordenados alfabéticamente
        return (2, filename)

    # Espacio basandome en ese y aplicamos el sort
    for file in sorted(notes_dictionary.keys(), key=sort_notes):
        spaces_number = current - len(file)
        spaces = " " * spaces_number

        print(f"{file}{FIXED_SPACES}{spaces}{ICON} {notes_dictionary[file][0]}")
else:
    # Estamos buscando
    filename = NOTE.split("    ")[0].strip()

    for root, _, files in os.walk(NOTES_DIR):
        if any(dir.startswith(".") for dir in root):
            continue

        if filename in files:
            path = os.path.join(root, filename)
            print(path)
            break
