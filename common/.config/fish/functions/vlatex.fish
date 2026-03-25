function vlatex
    # Si se le pasa un argumento lo usa, si no, lee de la tubería (stdin)
    set -l input
    if isatty stdin
        set input $argv[1]
    else
        read -z input
    end

    # Usamos python para renderizar el string rápidamente
    python3 -c "
import matplotlib.pyplot as plt
import sys
try:
    plt.rc('text', usetex=False) # Usa el motor interno de mathtext, más rápido
    fig = plt.figure(figsize=(len('$input')/5, 2))
    plt.text(0.5, 0.5, r'\$""$input""\$', size=30, ha='center', va='center', fontfamily='serif')
    plt.axis('off')
    plt.show()
except Exception as e:
    print(f'Error de renderizado: {e}')
"
end
