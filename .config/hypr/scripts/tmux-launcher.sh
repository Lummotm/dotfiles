#!/bin/bash

# Función para verificar si existe una sesión de tmux
check_tmux_session() {
    tmux has-session 2>/dev/null
}

# Función para obtener el número de clientes conectados
get_attached_clients() {
    tmux list-clients | wc -l
}

# Función principal
handle_tmux() {
    if [ -n "$TMUX" ]; then
        # Si estamos dentro de tmux, salir
        tmux detach-client
        exit 0
    fi

    if check_tmux_session; then
        # Si hay una sesión existente
        clients=$(get_attached_clients)
        if [ "$clients" -gt 0 ]; then
            # Si hay clientes conectados, desconectarlos
            tmux list-clients | cut -d: -f1 | xargs -n 1 tmux detach-client -t
        fi
        # Conectar a la sesión
        exec tmux attach
    else
        # Si no hay sesión, crear una nueva
        exec tmux new-session
    fi
}

# Ejecutar
handle_tmux
