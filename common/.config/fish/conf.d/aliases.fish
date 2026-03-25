# Alias generales
set -gx EZA_DEFAULT_OPTS '--icons --color=auto --group-directories-first --sort=type --follow-symlinks'
       


if type -q eza 
    alias ll "eza -l $EZA_DEFAULT_OPTS --git"
    alias ls "eza $EZA_DEFAULT_OPTS"
end

alias clc   'clear'
# alias pc    'python3 -i ~/Projects/Python/calc.py'

# Hotspot wifi (adaptar si cambia la interfaz)
alias media-grabber="$HOME/bin/terminal-tools/media-grabber"
alias ff="fastfetch"
alias f="directory-picker"

