import os

FILE_PATH = os.path.expanduser("~/.cache/wal/custom-kitty.conf")
DEST_PATH = os.path.expanduser("~/.config/sioyek/prefs_user.config")


def process_color(color_type, colors_hex):
    # Extraemos los pares directamente por su posición
    # Rojo: posición 0 y 1 | Verde: 2 y 3 | Azul: 4 y 5
    r_hex = colors_hex[0:2]
    g_hex = colors_hex[2:4]
    b_hex = colors_hex[4:6]

    # Convertimos a entero y normalizamos dividiendo por 255
    r_norm = round(int(r_hex, 16) / 255, 2)
    g_norm = round(int(g_hex, 16) / 255, 2)
    b_norm = round(int(b_hex, 16) / 255, 2)

    # Lo del .2f es para 2 decimales pero ns pq hace falta si en teoria ya lo hace
    return f"{color_type} {r_norm:.2f} {g_norm:.2f} {b_norm:.2f}"


background_line = ""
foreground_line = ""

if os.path.exists(FILE_PATH):
    with open(FILE_PATH, "r") as f:
        for line in f:
            if "background" in line and "#" in line:
                clean = line.split("#")[1].strip()
                background_line = process_color("custom_background_color", clean)
            if "foreground" in line and "#" in line:
                clean = line.split("#")[1].strip()
                foreground_line = process_color("custom_text_color", clean)

if os.path.exists(DEST_PATH):
    with open(DEST_PATH, "r") as f:
        lines = f.readlines()

    new_content = []
    for line in lines:
        # Reemplazamos las líneas específicas si coinciden

        if "custom_background_color" in line and background_line:
            new_content.append(background_line + "\n")
        elif "custom_text_color" in line and foreground_line:
            new_content.append(foreground_line + "\n")
        else:
            new_content.append(line)

    with open(DEST_PATH, "w") as f:
        f.writelines(new_content)
