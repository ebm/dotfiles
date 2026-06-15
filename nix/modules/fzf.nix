{
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
