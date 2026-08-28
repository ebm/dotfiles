{ pkgs, ... }: {
  imports = [
    ../modules/rnnoise.nix
  ];

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
  ];

  # Extra Packages:
  #   brightnessctl
  #   foot
  #   grim
  #   pulseaudio
  #   swayidle
  #   swaylock
  #   wmenu
  programs.sway.enable = true;

  # After swayidle suspends, systemd hibernates once idle this long in RAM.
  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'sway --unsupported-gpu'";
      };
    };
  };

  security.rtkit.enable = true;

  programs.obs-studio = {
    enable = true;
  };

  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };
}
