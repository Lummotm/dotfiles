# ─────────────────────────────────────────────────────────────────────────────
#  FISH SHELL CONFIG
#  Author: Lummotm
#  Last updated: 2025‑05‑09
# ─────────────────────────────────────────────────────────────────────────────

if not status is-interactive
    exit
end

# 1. Pager de man pages en Neovim ─────────────────────────────────────────────
set -gx MANPAGER 'nvim +Man!'

# 2. Starship prompt ─────────────────────────────────────────────────────────
if type -q starship
    starship init fish | source
end

