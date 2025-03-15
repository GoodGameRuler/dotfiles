# The following lines were added by compinstall

source ~/.bashrc

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=** r:|=**'
zstyle ':completion:*' max-errors 3
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=3000
SAVEHIST=3000
setopt autocd
unsetopt beep


# enable colours in less
export LESS=-XR

# For man pages
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# sets up vi mode and backspacing
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
bindkey "^[[3~" delete-char

# End of lines configured by zsh-newuser-install


autoload -U colors && colors
PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~ %{$reset_color%}% "
#
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats "%F{010}(%b)%f "
precmd() {
    vcs_info
}
#
setopt prompt_subst
# PROMPT='${vcs_info_msg_0_}%# '

PROMPT='%B%F{green}${PWD/#$HOME/~} %F{white}$%F{reset_color} ${vcs_info_msg_0_}%b'
# autoload -Uz promptinit
# promptinit
# prompt adam2

# Colourful LS
alias ls="ls --color=always"
alias la="ls -lA"
alias nv=nvim
alias nsb="nvim ~/OrgNotes/"
alias t="tree -CL 3"

# Clear without clearing scroll
alias cl="clear -x"
alias cls=clear

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'"

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# export PAGER=most
export MANPAGER='nvim +Man!'

export ZK_NOTEBOOK_DIR="~/Norg"

### PATH
# Optimising For
export PATH=$PATH:~/.local/share/bob/nvim-bin

# Rergular
export PATH=/usr/local/texlive/2024/bin/x86_64-linux:$PATH;
export PATH=$HOME/go/bin:$PATH;

export MANPATH=/usr/local/texlive/2024/texmf-dist/doc/man:$MANPATH;

export INFOPATH=/usr/local/texlive/2024/texmf-dist/doc/info:$INFOPATH;

export PATH=$PATH:~/Progs/miniconda3/bin
export PATH=$PATH:~/.cargo/bin

export XDG_CONFIG_HOME="$HOME/.config"


source ~/.zsh_plugins

source /usr/share/nvm/init-nvm.sh

umirr () {
    sudo reflector --protocol https --connection-timeout 10 --age 24 --completion-percent 97 --latest 200 --fastest 50 --score 10 --sort rate --verbose --save /etc/pacman.d/mirrorlist
}

alias s="source ~/.zshrc"
alias arch='uname -m'

# Allow for driectory based pathing
eval "$(direnv hook zsh)"
alias container='make -C ~/Projects/seL4-CAmkES-L4v-dockerfiles user HOST_DIR=$(pwd)'


## Run tmux if interactive and not already open
# case $- in *i*)
#     if [ -z "$TMUX" ]; then tmux new -A -s default ; fi;;
# esac

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

. "$HOME/.local/bin/env"
