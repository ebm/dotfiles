{
  pkgs,
  config,
  lib,
  ...
}:

let
  mod = "Mod4";
  wallpaper = ./wallpapers/zuko_vs_azula.jpg;
  swaylockcmd = "swaylock --image ${wallpaper} --scaling fill";
in
{
  xdg.configFile."swaylock/config".text = ''
    image=${wallpaper}
    scaling=fill
    ignore-empty-password
    show-failed-attempts
  '';

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = mod;
      terminal = "foot";
      menu = "wmenu-run";

      defaultWorkspace = "workspace number 1";

      output = {
        "*" = {
          bg = "${wallpaper} fill";
        };
      };

      input = {
        "*" = {
          xkb_options = "caps:escape_shifted_capslock";
          repeat_rate = "50";
          repeat_delay = "300";
          scroll_button = "button2";
          scroll_method = "on_button_down";
          scroll_button_lock = "disabled";
          scroll_factor = "1";
        };
        "type:pointer" = {
          accel_profile = "flat";
          pointer_accel = "0";
        };
      };

      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec foot";
        "${mod}+b" = "exec librewolf";
        "${mod}+y" = "exec discord";
        "${mod}+d" = "exec wmenu-run";

        "${mod}+Shift+s" = "exec screenshot";
        "Print" = "exec screenshot --fullscreen";
        "${mod}+Shift+Delete" = "exec ${swaylockcmd}";

        "${mod}+Shift+q" = "kill";
        "${mod}+f" = "fullscreen";
        "${mod}+n" = "splith";
        "${mod}+v" = "splitv";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";
        "${mod}+a" = "focus parent";
        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";

        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes, exit sway' 'swaymsg exit'";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "--locked XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "--locked XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "--locked XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "--locked XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "--locked XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "--locked XF86MonBrightnessUp" = "exec brightnessctl set 5%+";

        "${mod}+r" = "mode resize";
        "${mod}+s" = null;
        "${mod}+w" = null;
        "${mod}+e" = null;
      };

      modes = {
        resize = {
          h = "resize shrink width 10px";
          j = "resize grow height 10px";
          k = "resize shrink height 10px";
          l = "resize grow width 10px";
          Left = "resize shrink width 10px";
          Down = "resize grow height 10px";
          Up = "resize shrink height 10px";
          Right = "resize grow width 10px";
          Return = "mode default";
          Escape = "mode default";
        };
      };

      colors = {
        focused = {
          border = "#cba6f7";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#cba6f7";
          childBorder = "#cba6f7";
        };
        focusedInactive = {
          border = "#45475a";
          background = "#1e1e2e";
          text = "#a6adc8";
          indicator = "#45475a";
          childBorder = "#45475a";
        };
        unfocused = {
          border = "#313244";
          background = "#1e1e2e";
          text = "#a6adc8";
          indicator = "#313244";
          childBorder = "#313244";
        };
        urgent = {
          border = "#f38ba8";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#f38ba8";
          childBorder = "#f38ba8";
        };
      };

      gaps = {
        inner = 10;
        outer = 5;
      };

      window.border = 2;
      window.titlebar = false;
      floating.border = 2;
      floating.titlebar = false;
      floating.modifier = mod;
      bars = [ ];

      startup = [
        {
          command = "swayidle -w timeout 60 'pgrep -x swaylock && swaymsg \"output * power off\"' resume 'swaymsg \"output * power on\"' timeout 300 'pgrep -x swaylock && systemctl suspend' before-sleep '${swaylockcmd} -f'";
        }
      ];
    };
  };
}
