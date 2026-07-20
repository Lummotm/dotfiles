#!/usr/bin/env bash

FZF_CMD="fzf --margin 25%,25% --border --layout=reverse --prompt='Search File: '"

# Selección de motor de busqueda, priorizamos fd que es más rápìdo, sino esta a fallbaack
if command -v fd >/dev/null 2>&1; then
    SEARCH_CMD="fd -H --no-hidden -t f"
else
    SEARCH_CMD="find . -mindepth 1 ! -path '*/.git/*' -type f"
fi

SELECTED=$(eval "$SEARCH_CMD" 2>/dev/null | eval "$FZF_CMD --header='FZF FILES'")

if [ -n "$SELECTED" ]; then
    # Integramos con yazi
    TARGET="$(realpath "$SELECTED")"
    ya emit reveal "$TARGET" 2>/dev/null || ya pub dds-reveal --str "$TARGET" 2>/dev/null
fi

exit 0
