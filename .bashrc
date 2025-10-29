#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export QSYS_ROOTDIR="/home/udit/.cache/yay/quartus-free/pkg/quartus-free-quartus/opt/intelFPGA/24.1/quartus/sopc_builder/bin"

# Git branch with status colors
parse_git_branch() {
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    
    if [ -n "$branch" ]; then
        local color="32"  # green by default
        
        # Check for untracked files first
        if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
            color="31"  # red - untracked files
        # Check for unstaged changes
        elif ! git diff-index --quiet HEAD -- 2>/dev/null; then
            color="31"  # red - unstaged changes
        # Check for staged but uncommitted changes
        elif ! git diff-index --quiet --cached HEAD -- 2>/dev/null; then
            color="33"  # yellow - staged changes
        # Check for unpushed commits
        elif [ -n "$(git log @{u}.. 2>/dev/null)" ]; then
            color="33"  # yellow - unpushed commits
        fi
        
        printf "\001\033[1;${color}m\002(%s) \001\033[0m\002" "$branch"
    fi
}

# Update prompt
PROMPT_COMMAND='PS1_GIT=$(parse_git_branch)'

# Prompt
PS1='\[\033[1;37m\][BASH] \[\033[1;32m\]\w \[\033[1;37m\]\$\[\033[0m\] ${PS1_GIT}'

eval "$(fzf --bash)"

# History settings
HISTFILE=~/.bash_histfile
HISTSIZE=10000
SAVEHIST=10000

# Clear aliases
alias cl='clear -x'       # Soft clear
alias cls='clear'         # Hard clear (original behavior)`
source -- ~/.local/share/blesh/ble.sh

set -o vi
