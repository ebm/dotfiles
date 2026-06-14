{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      vim = "nvim";
      sc = "screenshot";
      scs = "saved-screenshots";
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./.;
        file = "p10k.zsh";
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];

    initContent = ''
      # Colored man pages
      export LESS_TERMCAP_md="$(tput bold 2>/dev/null; tput setaf 2 2>/dev/null)"
      export LESS_TERMCAP_me="$(tput sgr0 2>/dev/null)"

      # History substring search keybinds
      bindkey '^P' history-substring-search-up
      bindkey '^N' history-substring-search-down

      # dircolors
      if command -v dircolors >/dev/null 2>&1; then
          eval "$(TERM=xterm-256color dircolors -b)"
      fi
    '';
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--bind 'ctrl-j:down,ctrl-k:up'"
      "--bind 'ctrl-d:half-page-down,ctrl-u:half-page-up'"
      "--bind 'ctrl-/:toggle-preview'"
    ];
  };
}
