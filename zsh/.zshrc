# p10k instant prompt — must stay near top, before anything that prints
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups hist_ignore_space share_history inc_append_history

# Completion
autoload -Uz compinit
compinit

# Colored man pages
export LESS_TERMCAP_md="$(tput bold 2>/dev/null; tput setaf 2 2>/dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2>/dev/null)"

# Prompt: powerlevel10k
typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
source "/run/current-system/sw/share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme"
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# History substring search + Ctrl-P / Ctrl-N binds
source "/run/current-system/sw/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# fzf shell integration (Ctrl-R / Ctrl-T / Alt-C)
# vim-style navigation: Ctrl-J/K to move, Ctrl-U/D to half-page scroll, Ctrl-/ toggles preview
export FZF_DEFAULT_OPTS="
  --bind 'ctrl-j:down,ctrl-k:up'
  --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up'
  --bind 'ctrl-/:toggle-preview'
"
source <(fzf --zsh)


# ls colors — use xterm-256color so dircolors always finds the color database
# (foot supports all xterm-256color sequences; TERM=foot has no dircolors entry)
if command -v dircolors >/dev/null 2>&1; then
    eval "$(TERM=xterm-256color dircolors -b)"
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
alias sc='screenshot'
alias nrs="sudo nixos-rebuild switch --flake ~/dotfiles/nix#laptop"
alias ec="sudo -E nvim /etc/nixos/"
