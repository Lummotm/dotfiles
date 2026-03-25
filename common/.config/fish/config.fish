if not status is-interactive
    exit
end

# Added to path 
set -gx PATH ~/.local/bin $PATH
set -gx NNN_OPENER xdg-open

# Variables de entorno globales
if type -q nvim
    set -gx EDITOR nvim
    set -gx MANPAGER 'nvim +Man!'
    set -gx PAGER 'nvim +Man!'
end

if type -q zen-browser 
    set -gx BROWSER zen-browser
else
    set -gx BROWSER firefox
end


# Starship prompt
if type -q starship
    starship init fish | source
end

# Keybinds need to be sourced
if test -f ~/.config/fish/functions/fish_user_key_bindings.fish
    source ~/.config/fish/functions/fish_user_key_bindings.fish
end

# Zoxide initialization (only if installed)
if type -q zoxide
    zoxide init fish | source
end

if type -q yazi 
    # Use y instead of yazi to change the CWD when exit
    source ~/.config/fish/functions/y.fish
end

source ~/.config/fish/functions/fish_python_venv_directory_change.fish
source ~/.config/fish/functions/encrypt.fish 
