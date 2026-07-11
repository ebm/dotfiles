{ pkgs, ... }:

{
  imports = [
    ../configuration-common.nix
    ../graphical-common.nix
    ../../modules/nvidia.nix
    ../../modules/moza.nix
    ./disko-config.nix
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
