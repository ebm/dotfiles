{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "ethan";
  home.homeDirectory = "/home/ethan";

  imports = [ ./modules/nixvim.nix ];

  home.packages = with pkgs; [
    librewolf
    stow
    tree-sitter
    claude-code
    clang
    lua-language-server
    pyright
    jdt-language-server
    stylua
    nixfmt
    black
    gnumake
    fzf
    ripgrep
    fd
    tree
    wget
    tldr
    python3
    discord
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 16;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "26.05";
}
