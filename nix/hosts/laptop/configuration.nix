{ ... }:

{
  imports = [
    ../configuration-common.nix
    ../graphical-common.nix
    ../../modules/thinkpad-mute-led.nix
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  # Closing the lid suspends, then hibernates after HibernateDelaySec in RAM.
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  programs.captive-browser = {
    enable = true;
    interface = "wlp1s0";
  };

  system.stateVersion = "26.05";
}
