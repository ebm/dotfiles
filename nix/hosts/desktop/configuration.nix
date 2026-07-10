{ pkgs, ... }:

{
  imports = [
    ../configuration-common.nix
    ../graphical-common.nix
    ./hardware-configuration.nix
  ];

  system.stateVersion = "26.05";

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    lutris
    # wineWowPackages.staging
    # winetricks
  ];
}
