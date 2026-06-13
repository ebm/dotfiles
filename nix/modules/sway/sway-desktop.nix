{ lib, config, ... }:
let
  cfg = config.mine.sway;
in
{
  config = lib.mkIf (cfg.enable && cfg.machine == "desktop") {
    wayland.windowManager.sway.config = {
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
}
