#!/usr/bin/env bash

# --exact for it to not pick wrong paths like obsidian with bin
# --no-sort for it to not ignore the score given by zoxide
FZF_CMD="fzf --no-sort --exact --margin 25%,25% --border --layout=reverse --prompt='Jump to: '"
SELECTED=$(zoxide query -ls | eval "$FZF_CMD --header='ZOXIDE'")

# -l lists, -s gives also the score
if [ -z "$SELECTED" ]; then
    exit 0
fi
CLEAN="/${SELECTED#*/}" # Delete score before, its before the first / readd the first /
echo "$CLEAN"

if [ -n "$CLEAN" ]; then
    # Integramos cn yazi
    ya emit cd -- "$CLEAN" 2>/dev/null
fi

exit 0
