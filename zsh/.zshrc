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

ZSH_PLUGINS="$HOME/.zsh/plugins"

# Prompt: powerlevel10k
typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
[[ -f "$ZSH_PLUGINS/powerlevel10k/powerlevel10k.zsh-theme" ]] && \
    source "$ZSH_PLUGINS/powerlevel10k/powerlevel10k.zsh-theme"
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Autosuggestions
[[ -f "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"

# History substring search + Ctrl-P / Ctrl-N binds
[[ -f "$ZSH_PLUGINS/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] && \
    source "$ZSH_PLUGINS/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# fzf shell integration (Ctrl-R / Ctrl-T / Alt-C)
if command -v fzf >/dev/null 2>&1; then
    if fzf --zsh >/dev/null 2>&1; then
        source <(fzf --zsh)
    else
        for f in /usr/share/fzf/key-bindings.zsh \
                 /usr/share/fzf/completion.zsh \
                 /usr/share/doc/fzf/examples/key-bindings.zsh \
                 /usr/share/doc/fzf/examples/completion.zsh; do
            [[ -f "$f" ]] && source "$f"
        done
    fi
fi

# Syntax highlighting — must be sourced LAST per upstream docs
[[ -f "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
