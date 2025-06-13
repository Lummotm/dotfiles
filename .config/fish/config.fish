# ─────────────────────────────────────────────────────────────────────────────
#  FISH SHELL CONFIG
#  Author: Lummotm
#  Last updated: 2025‑05‑17
# ─────────────────────────────────────────────────────────────────────────────

if not status is-interactive
    exit
end

# Variables de entorno globales
set -gx EDITOR nvim
set -gx MANPAGER 'nvim +Man!'
set -gx PAGER "nvim -"

# Ruta de fisher (en caso de fallback)
set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
set -g fisher_path $XDG_CONFIG_HOME/fish/functions/fisher.fish
test -f $fisher_path; and source $fisher_path

# Starship prompt
if type -q starship
    starship init fish | source
end

# Activar función reactiva de ls al cambiar de directorio
source ~/.config/fish/functions/_auto_ls_after_cd.fish

# Activar fish_vi_key_bindings
fish_vi_key_bindings

function prime-run
    env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia $argv
end
