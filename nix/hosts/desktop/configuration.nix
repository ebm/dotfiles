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

  # Lofree Flow84 uses the hid_apple driver; fnmode=2 makes F1-F12 primary
  boot.kernelParams = [ "hid_apple.fnmode=2" ];

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    lutris
    # wineWowPackages.staging
    # winetricks
  ];
}
