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

  # Windows dual-boots from a separate SSD; efibootmgr manages the EFI BootOrder
  environment.systemPackages = [ pkgs.efibootmgr ];

  programs.steam.enable = true;

  time.hardwareClockInLocalTime = true;
}
