{ ... }:

{
  imports = [
    ../configuration-common.nix
    ../graphical-common.nix
    ./hardware-configuration.nix
  ];

  system.stateVersion = "26.05";
}
