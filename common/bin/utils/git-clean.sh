#!/usr/bin/env bash
set -euo pipefail

GIT_PATH=""
FORCE="false"

for arg in "$@"; do
  case "$arg" in
  -f | --force)
    FORCE="true"
    ;;
  *)
    if [[ -z "$GIT_PATH" ]]; then
      GIT_PATH="$arg"
    fi
    ;;
  esac
done

if [[ -z "$GIT_PATH" ]]; then
  echo "Error: Se espera un directorio."
  echo "Uso: $0 <directorio> [--force]"
  exit 1
fi

if [[ ! -d "$GIT_PATH" ]]; then
  echo "Error: El directorio '$GIT_PATH' no existe."
  exit 1
fi

clean_git_history() {
  if [[ "$FORCE" != "true" ]]; then
    clear
    echo "ADVERTENCIA: Esto borrará TODO el historial de commits de: $GIT_PATH"
    echo "Se quedará solo con el estado actual como un único commit."
    read -rp "¿Estás seguro? (s/n): " confirm

    if [[ "$confirm" != "s" ]]; then
      echo "Operación cancelada."
      return 1
    fi
  fi

  cd "$GIT_PATH"

  # 1. Crear rama huérfana (sin historial)
  git checkout --orphan latest_branch

  # 2. Añadir todos los archivos actuales
  git add -A

  # 3. Primer commit de la nueva era
  git commit -m "Clean state: $(date +'%Y-%m-%d %H:%M')"

  # 4. Borrar la rama principal vieja y renombrar la actual
  git branch -D main
  git branch -m main

  # 5. Push forzado para sobreescribir el remoto
  echo "Subiendo cambios al servidor..."
  git push -f origin main

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Git" "Historial de $GIT_PATH limpiado correctamente"
  fi
}

clean_git_history
