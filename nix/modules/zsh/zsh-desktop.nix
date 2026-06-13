{ config, lib, ... }:
let
  cfg = config.mine.zsh;
in
{
  options.mine.zsh.desktop = lib.mkEnableOption "zsh";
  config = lib.mkIf cfg.desktop {
    programs.zsh.shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/dotfiles/nix#desktop";
    };
  };
}
