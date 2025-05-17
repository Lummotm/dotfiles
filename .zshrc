# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Setting zinit home directory

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Install zinit if it doesn't exist
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# Install / load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Install powerlevel10k 
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Changes cursor to |
echo -ne '\e[5 q'

# Add in zsh plugins
zinit light zsh-users/zsh-autosuggestions


# Load completions
autoload -U compinit && compinit


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Crear un widget de la función 
__zoxide_zi_widget() {
    __zoxide_zi 
    zle reset-prompt
}



# Registrar el widget
zle -N __zoxide_zi_widget

# Asignar el key binding
bindkey '^f' __zoxide_zi_widget



# History

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"

# Aliases
alias ls='ls --color'
alias zox="__zoxide_zi"
alias ll='ls -la'
alias vi="nvim"
alias vim="nvim"
alias hotspot="~/./Projects/Bash/hotspot.sh"
alias connect_WH1000XM3="~/./Projects/Bash/connect_WH1000XM3.sh" 
alias clc="clear"
alias suvi="sudo -E nvim"
alias visu="sudo -E nvim"
alias ..="cd .." 
alias pc="python3 -i ~/Projects/Python/calc.py"
alias pycalc="pc"
alias hyprshot-fixed='hyprshot -m output -o ~/Pictures/Screenshots/'


# Shell Integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

