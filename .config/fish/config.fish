if status is-interactive
    # Commands to run in interactive sessions can go here
end

abbr vim nvim 
abbr vi nvim 

abbr gc "git commit -m"
abbr gp "git push -u origin main"

alias ll="eza -l --git --icons --color=auto --group-directories-first --sort=extension"
alias ls="eza --icons --color=auto --group-directories-first --sort=extension"
alias hotspot="/home/davidn/Projects/Bash/hotspot.sh"

set -gx MANPAGER 'nvim +Man!'

# Starship Theme Initialization
starship init fish | source
