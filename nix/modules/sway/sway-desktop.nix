{ lib, config, osConfig, ... }:
{
  config = lib.mkIf (osConfig.mine.host == "desktop") {
    wayland.windowManager.sway = {
      config = {
        output = {
          "HDMI-A-1" = {
            resolution = "1920x1080@240Hz";
            position = "0 0";
          };
          "DP-1" = {
            resolution = "1920x1080@144Hz";
            position = "1920 0";
          };
        };
      };
      extraConfig = ''
        workspace 1 output HDMI-A-1
        workspace 2 output HDMI-A-1
        workspace 3 output HDMI-A-1
        workspace 4 output HDMI-A-1
        workspace 5 output HDMI-A-1
        workspace 6 output DP-1
        workspace 7 output DP-1
        workspace 8 output DP-1
        workspace 9 output DP-1
        workspace 10 output DP-1
      '';
    };
  };
}
