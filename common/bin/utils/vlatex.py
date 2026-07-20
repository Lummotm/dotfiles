import argparse
import sys

import matplotlib.pyplot as plt


def mostrar_latex(latex_str: str):
    # Asegurar delimitadores de LaTeX
    if not latex_str.strip().startswith("$"):
        latex_str = f"${latex_str}$"

    # Crear la figura (ventana)
    fig, ax = plt.subplots(figsize=(8, 4))  # Tamaño base de la ventana

    # Ocultar los ejes y el marco
    ax.axis("off")
    fig.patch.set_visible(False)

    # Colocar el texto en el centro
    ax.text(0.5, 0.5, latex_str, fontsize=20, ha="center", va="center", color="black")

    # Cambiar el título de la ventana (opcional, para que se vea más profesional)
    fig.canvas.manager.set_window_title("Visor LaTeX")

    # Mostrar la ventana nativa de Matplotlib
    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("latex")

    try:
        args, _ = parser.parse_known_args()
        mostrar_latex(args.latex)
    except Exception:
        sys.exit(1)
