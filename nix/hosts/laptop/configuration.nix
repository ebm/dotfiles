{ ... }:

{
  imports = [
    ../configuration-common.nix
    ../graphical-common.nix
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  system.stateVersion = "26.05";
}
