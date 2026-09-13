export PATH="$HOME/.local/bin:$PATH"

# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Environment
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m'
alias gd='git diff'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias ff='fastfetch'
alias nrs='sudo nixos-rebuild switch'

# fzf shell completion & keybindings
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash 2>/dev/null || true)"
fi
alias nx-install="$HOME/.local/bin/nx-install"
