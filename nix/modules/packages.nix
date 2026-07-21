{ pkgs, ... }: {
  home.packages = with pkgs; [
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
    ripgrep
    fd
    tree
    wget
    tldr
    python3
    btop
    gradle
    sqlite
    jdk
    tectonic
    nvimpager
  ];
}
