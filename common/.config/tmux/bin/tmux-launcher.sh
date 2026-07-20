#!/usr/bin/env bash

# Si estamos dentro de tmux, salir de la sesión (detach)
if [ -n "$TMUX" ]; then
    tmux detach-client
    exit 0
fi

# Prefijo para nuestras terminales genéricas (así no chocan con tus proyectos)
PREFIX="term-"

# Buscamos el primer "tag" o slot (del 1 al 10) que esté libre
for i in {1..10}; do
    session_name="${PREFIX}${i}"

    # Comprobamos si la sesión ya existe
    if tmux has-session -t "$session_name" 2>/dev/null; then
        # Si existe, miramos si tiene clientes conectados (ventanas de Kitty usándola)
        attached=$(tmux list-sessions -F "#{session_name} #{session_attached}" | grep "^${session_name} " | awk '{print $2}')

        if [ "$attached" -eq 0 ]; then
            # Está huérfana (libre), nos conectamos para recuperar el estado
            exec tmux attach -t "$session_name"
        fi
        # Si tiene clientes conectados, el bucle continúa buscando el siguiente número
    else
        # La sesión no existe, creamos una nueva con este nombre ("tag")
        exec tmux new-session -s "$session_name"
    fi
done

# Fallback de seguridad: si logras tener 10 terminales abiertas a la vez,
# simplemente abre una sesión genérica sin nombre.
exec tmux new-session
