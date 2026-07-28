{ pkgs, ... }:

{
  imports = [
    ../home-common.nix
    ../graphical-home.nix
  ];

  home.packages = with pkgs; [
    lutris
    prismlauncher
    # wineWowPackages.staging
    # winetricks
  ];
}
