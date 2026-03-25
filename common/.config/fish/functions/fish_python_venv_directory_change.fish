function fish_python_venv_directory_change --on-variable PWD
    if test -f "$PWD/.venv/bin/activate.fish"
        source "$PWD/.venv/bin/activate.fish"
    else
        if set -q VIRTUAL_ENV
            # Desactiva si ya no estás en un directorio con .venv y hay un entorno activo
            if not string match --quiet "$VIRTUAL_ENV"* "$PWD"
                if functions -q deactivate
                    deactivate
                end
            end
        end
    end
end
