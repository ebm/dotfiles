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
    defaultEditor = true;
    globals.mapleader = " ";
    colorschemes.catppuccin.enable = true;
    diagnostics = {
      virtual_text = true;
    };
  };
}
