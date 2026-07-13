{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
        '';
      }
    ];
    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    historyLimit = 50000;
    terminal = "tmux-256color";
    extraConfig = ''
      # advertise truecolor support for the outer terminal (foot)
      set -ga terminal-features ",foot:RGB"

      set -g status-position top
      set -g status-right ""

      # Ctrl-Space enters copy mode, but is passed through to nvim
      # where blink-cmp uses it to open the completion menu
      bind -n C-Space if -F '#{m:*vim*,#{pane_current_command}}' 'send C-Space' 'copy-mode'

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi V send -X select-line
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"
      bind -T copy-mode-vi Escape send -X cancel
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "wl-copy"
    '';
  };
}
