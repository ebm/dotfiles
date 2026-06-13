{ config, lib, ... }:
let
  cfg = config.mine.zsh;
in
{
  options.mine.zsh.laptop = lib.mkEnableOption "zsh";
  config = lib.mkIf cfg.laptop {
    programs.zsh.shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/dotfiles/nix#laptop";
    };
  };
}
