# Alias generales
set -gx EZA_DEFAULT_OPTS '--icons --color=auto --group-directories-first --sort=type'

alias ll "eza -l $EZA_DEFAULT_OPTS --git"
alias ls "eza $EZA_DEFAULT_OPTS"

alias clc   'clear'
alias pc    'python3 -i ~/Projects/Python/calc.py'
alias a     'z'


# Hotspot wifi (adaptar si cambia la interfaz)
alias hotspot 'nmcli device wifi hotspot ifname wlan0 ssid ThinkingRock band bg password ThinkingRock123 && nmcli dev wifi show-password'

# Safe update with backup from timeshift previous to update
alias safe-update='sudo timeshift --create --comments "Antes de yay -Syu" --tags D; and yay -Syu'


