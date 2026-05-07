# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh

unsetopt correct
unsetopt correct_all

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias vim='nvim'

# zsh-vi-mode
ZVM_PLUGIN_PATH="$HOME/.zsh/zsh-vi-mode"
if [[ ! -d "$ZVM_PLUGIN_PATH" ]]; then
  git clone https://github.com/jeffreytse/zsh-vi-mode "$ZVM_PLUGIN_PATH"
fi
source "$ZVM_PLUGIN_PATH/zsh-vi-mode.plugin.zsh
