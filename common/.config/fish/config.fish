if not status is-interactive
    exit
end

# Borrado de variable global antigua
set --erase --universal fish_key_bindings

# PATH
set -gx PATH ~/.cargo/bin ~/.local/bin $PATH

# Variables de entorno globales
if type -q nvim
    set -gx EDITOR nvim
    set -gx MANPAGER 'nvim +Man!'
end
set -gx YT_X_FZF_OPTS "--color=bg:-1,bg+:-1,gutter:-1,hl:#5f87af,hl+:#5fd7ff,prompt:#d7005f,pointer:#af5fff,marker:#87ff00,border:#262626"

if type -q zen-browser 
    set -gx BROWSER zen-browser
else if type -q firefox
    set -gx BROWSER firefox
end

# BINDS

# fish_vi_key_bindings is now baked into fish, no need for the old .fish binary with the info
set --global fish_key_bindings fish_vi_key_bindings

if type -q fzf_key_bindings
    fzf_key_bindings
end

# PLUGINS
# Starship prompt
if type -q starship
    starship init fish | source
end

# Zoxide initialization (only if installed)
if type -q zoxide
    zoxide init fish | source
end

if type -q yazi 
    # Use y instead of yazi to change the CWD when exit
    source ~/.config/fish/functions/y.fish
end


source ~/.config/fish/conf.d/abbr.fish
source ~/.config/fish/conf.d/aliases.fish
source ~/.config/fish/conf.d/theme.fish

