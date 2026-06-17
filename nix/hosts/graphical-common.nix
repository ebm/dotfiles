{ pkgs, ... }: {
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

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
      };
    };
  };

  security.rtkit.enable = true;

  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };
}
