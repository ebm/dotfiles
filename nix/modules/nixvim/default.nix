{ inputs, ... }: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./options.nix
    ./keymaps.nix
    ./plugins.nix
    ./autocmds.nix
  ];

  programs.nixvim = {
    enable = true;
    nixpkgs.useGlobalPackages = true;
    defaultEditor = true;
    globals.mapleader = " ";
    colorschemes.catppuccin.enable = true;
    diagnostic.settings = {
      virtual_text = false;
      virtual_lines.current_line = true;
    };
  };
}
