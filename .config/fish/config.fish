if status is-interactive
    # Commands to run in interactive sessions can go here
end

abbr vim nvim 
abbr vi nvim 

abbr gc "git commit -m"
abbr gp "git push -u origin main"

alias ll="eza -l --git --icons --color=auto --group-directories-first --sort=extension --sort=name"
alias ls="eza --icons --color=auto --group-directories-first --sort=extension --sort=name"
alias hotspot="/home/davidn/Projects/Bash/hotspot.sh"
alias clc="clear"
alias pc="python3 -i /home/davidn/Projects/Python/calc.py"
alias a="z"


set -gx MANPAGER 'nvim +Man!'

function __auto_ls_after_cd --on-variable PWD
    ls
end

# Starship Theme Initialization
starship init fish | source
