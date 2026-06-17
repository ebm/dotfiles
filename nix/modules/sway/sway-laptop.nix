{ lib, config, osConfig, ... }:
{
  config = lib.mkIf (osConfig.mine.host == "laptop") {
    wayland.windowManager.sway = {
      config = {
        output = {
          "eDP-1" = {
            resolution = "1920x1200";
            position = "0 0";
            scale = "1.5";
          };
        };
        input = {
          "type:touchpad" = {
            click_method = "clickfinger";
            natural_scroll = "enabled";
            dwt = "enabled";
            middle_emulation = "enabled";
            accel_profile = "adaptive";
            scroll_method = "two_finger";
          };
        };
      };
      extraConfig = ''
        bindswitch --reload --locked lid:on output eDP-1 disable
        bindswitch --reload --locked lid:off output eDP-1 enable
      '';
    };
  };
}
