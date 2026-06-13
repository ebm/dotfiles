{ lib, config, ... }:
let
  cfg = config.mine.sway;
in
{
  config = lib.mkIf (cfg.enable && cfg.machine == "desktop") {
    wayland.windowManager.sway.config = {
      "eDP-1" = {
        resolution = "1920x1200";
        position = "0 0";
        scale = "1.5";
      };
    };
  };
}
