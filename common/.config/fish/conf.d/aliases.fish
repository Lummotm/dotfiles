if type -q eza 
    set -gx EZA_DEFAULT_OPTS '--icons --color=auto --group-directories-first --sort=type --follow-symlinks'
    alias ll "eza -l $EZA_DEFAULT_OPTS --git"
    alias ls "eza $EZA_DEFAULT_OPTS"
end
