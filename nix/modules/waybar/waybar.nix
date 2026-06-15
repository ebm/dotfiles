{ ... }: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [
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
          "pulseaudio"
          "network"
          "battery"
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

        "custom/gpu-usage" = {
          exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ' || cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1 || echo 0";
          format = "GPU {}%";
          interval = 2;
          tooltip = false;
        };

        "custom/gpu-temp" = {
          exec = ''nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ' || grep -l amdgpu /sys/class/hwmon/hwmon*/name 2>/dev/null | sed 's|name$|temp1_input|' | head -1 | xargs -r awk '{printf "%d", $1/1000}' || echo 0'';
          format = "{}°C";
          interval = 2;
          tooltip = false;
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

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 muted";
          format-icons = {
            headphone = "󰋋";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "pavucontrol";
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
    ];
  };
}
