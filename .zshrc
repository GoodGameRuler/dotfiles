# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=** r:|=**'
zstyle ':completion:*' max-errors 3
zstyle :compinstall filename '/home/udit/.zshrc'

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
alias nv=nvim

# Clear without clearing scroll
alias cl="clear -x"
alias cls=clear

# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'"

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# PATH
# export XDG_DATA_DIRS=$XDG_DATA_DIRS:~/.local/share/flatpak/exports/share
# export XDG_DATA_DIRS=$XDG_DATA_DIRS:~/.local/share/flatpak/exports/bin
# export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share

export PATH=$PATH:~/.local/share/bob/nvim-bin

export PATH=/usr/local/texlive/2024/bin/x86_64-linux:$PATH;

export MANPATH=/usr/local/texlive/2024/texmf-dist/doc/man:$MANPATH;

export INFOPATH=/usr/local/texlive/2024/texmf-dist/doc/info:$INFOPATH;

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
