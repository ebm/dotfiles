{ ... }:

{
  imports = [
    ../configuration-common.nix
    ./hardware-configuration.nix
    ./disko-config.nix
    ./rlcraft.nix
  ];

  system.stateVersion = "26.05";
}
