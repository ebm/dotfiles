{ ... }:

{
  imports = [
    ../configuration-common.nix
    ../graphical-common.nix
    ../../modules/thinkpad-mute-led.nix
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  programs.captive-browser = {
    enable = true;
    interface = "wlp1s0";
  };

  system.stateVersion = "26.05";
}
