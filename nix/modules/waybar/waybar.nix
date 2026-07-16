{ osConfig, lib, ... }:
let
  isLaptop = osConfig.mine.host == "laptop";
  isDesktop = osConfig.mine.host == "desktop";

  gpuModules =
    if isDesktop then
      {
        "custom/gpu-usage" = {
          exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | tr -d ' '";
          format = "GPU {}%";
          interval = 2;
          tooltip = false;
        };
        "custom/gpu-temp" = {
          exec = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | tr -d ' '";
          format = "{}°C";
          interval = 2;
          tooltip = false;
        };
      }
    else
      {
        "custom/gpu-usage" = {
          exec = "cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1";
          format = "GPU {}%";
          interval = 2;
          tooltip = false;
        };
        "custom/gpu-temp" = {
          exec = ''grep -l amdgpu /sys/class/hwmon/hwmon*/name 2>/dev/null | sed 's|name$|temp1_input|' | head -1 | xargs -r awk '{printf "%d", $1/1000}' '';
          format = "{}°C";
          interval = 2;
          tooltip = false;
        };
      };

  batteryModule = lib.optionalAttrs isLaptop {
    battery = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{icon} {capacity}%";
      format-charging = "󰂄 {capacity}%";
      format-plugged = "󰚥 {capacity}%";
      format-icons = [
        "󰁺"
        "󰁻"
        "󰁼"
        "󰁽"
        "󰁾"
        "󰁿"
        "󰂀"
        "󰂁"
        "󰂂"
        "󰁹"
      ];
      tooltip-format = "{timeTo}";
    };
  };
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [
      (
        {
          height = 30;
          spacing = 0;

          "modules-left" = [
            "sway/workspaces"
            "sway/mode"
            "sway/scratchpad"
          ];
          "modules-center" = [ ];
          "modules-right" = [
            "cpu"
            "temperature"
            "custom/gpu-usage"
            "custom/gpu-temp"
            "disk"
            "memory"
            "custom/mic"
            "pulseaudio"
            "network"
          ]
          ++ lib.optional isLaptop "battery"
          ++ [
            "clock"
            "tray"
          ];

          "sway/workspaces" = {
            disable-scroll = true;
          };

          "sway/mode" = {
            format = "<span style=\"italic\">{}</span>";
          };

          "sway/scratchpad" = {
            format = "{icon} {count}";
            show-empty = false;
            format-icons = [
              "󰚡"
              "󰚠"
            ];
            tooltip = true;
            tooltip-format = "{app}: {title}";
          };

          cpu = {
            format = "CPU {usage}%";
            tooltip = false;
            interval = 2;
          };

          temperature = {
            thermal-zone = 0;
            critical-threshold = 80;
            format = "{temperatureC}°C";
            format-critical = "{temperatureC}°C";
            interval = 2;
          };

          memory = {
            format = "{avail:0.1f}G free";
            tooltip-format = "{avail:0.1f}G available / {total:0.1f}G total";
            interval = 2;
          };

          disk = {
            path = "/";
            format = "{free} free";
            tooltip-format = "{used} used / {total} total on {path}";
            interval = 30;
          };

          network = {
            format-ethernet = "Ethernet";
            format-wifi = "{essid} {signalStrength}%";
            format-disconnected = "⚠ Disconnected";
            tooltip-format = "{ifname} — {ipaddr} via {gwaddr}";
          };

          "custom/mic" = {
            exec = ''
              if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q yes; then
                echo '{"text":"󰍭","tooltip":"Microphone muted","class":"muted"}'
              else
                vol=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -o '[0-9]*%' | head -1)
                echo "{\"text\":\"󰍬 $vol\",\"tooltip\":\"Microphone live\",\"class\":\"live\"}"
              fi
            '';
            return-type = "json";
            interval = 1;
            # on-click = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "󰝟";
            format-icons = {
              headphone = "󰋋";
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            # on-click = "pavucontrol";
            scroll-step = 5;
          };

          clock = {
            format = "{:%b %d %I:%M %p}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          tray = {
            spacing = 10;
          };
        }
        // gpuModules
        // batteryModule
      )
    ];
  };
}
