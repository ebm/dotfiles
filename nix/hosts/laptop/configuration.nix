{ ... }:

{
  imports = [
    ../configuration-common.nix
    ../graphical-common.nix
    ../../modules/thinkpad-mute-led.nix
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  system.stateVersion = "26.05";
}
