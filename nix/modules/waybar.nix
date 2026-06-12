{ ... }: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [
      {
        height = 30;
        spacing = 4;

        "modules-left" = [
          "sway/workspaces"
          "sway/mode"
          "sway/scratchpad"
        ];
        "modules-center" = [ ];
        "modules-right" = [
          "disk"
          "cpu"
          "temperature"
          "custom/gpu-usage"
          "custom/gpu-temp"
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
            ""
            ""
          ];
          tooltip = true;
          tooltip-format = "{app}: {title}";
        };

        cpu = {
          format = "CPU  {usage}%";
          tooltip = false;
          interval = 2;
        };

        temperature = {
          thermal-zone = 0;
          critical-threshold = 80;
          format = "CPU  {temperatureC}°C";
          format-critical = "CPU  {temperatureC}°C";
        };

        "custom/gpu-usage" = {
          exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ' || cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1 || echo 0";
          format = "GPU  {}%";
          interval = 2;
          tooltip = false;
        };

        "custom/gpu-temp" = {
          exec = ''nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ' || grep -l amdgpu /sys/class/hwmon/hwmon*/name 2>/dev/null | sed 's|name$|temp1_input|' | head -1 | xargs -r awk '{printf "%d", $1/1000}' || echo 0'';
          format = "GPU  {}°C";
          interval = 2;
          tooltip = false;
        };

        memory = {
          format = " {avail:0.1f}G free";
          tooltip-format = "{avail:0.1f}G available / {total:0.1f}G total";
          interval = 2;
        };

        disk = {
          path = "/";
          format = " {free} free";
          tooltip-format = "{used} used / {total} total on {path}";
          interval = 30;
        };

        network = {
          format-ethernet = " Ethernet";
          format-wifi = " {essid} {signalStrength}%";
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
          format = " {:%b %d %I:%M %p}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        tray = {
          spacing = 10;
        };
      }
    ];

    style = ''
      /* Catppuccin Mocha */
      * {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 13px;
          min-height: 0;
          border: none;
          border-radius: 0;
      }

      window#waybar {
          background-color: #1e1e2e;
          color: #cdd6f4;
      }

      #workspaces button {
          padding: 0 8px;
          color: #a6adc8;
          background: transparent;
      }

      #workspaces button:hover {
          background: #313244;
          color: #cdd6f4;
      }

      #workspaces button.focused {
          color: #1e1e2e;
          background: #cba6f7;
      }

      #workspaces button.urgent {
          background: #f38ba8;
          color: #1e1e2e;
      }

      #mode {
          padding: 0 8px;
      }

      #scratchpad {
          padding: 0 8px;
      }

      #pulseaudio,
      #network,
      #battery,
      #cpu,
      #disk,
      #temperature,
      #memory,
      #clock,
      #tray,
      #custom-gpu-usage,
      #custom-gpu-temp {
          padding: 0 10px;
          color: #cdd6f4;
          border-left: 1px solid #45475a;
      }

      #temperature.critical,
      #battery.critical,
      #network.disconnected {
          color: #f38ba8;
      }

      #temperature.critical,
      #battery.critical {
          animation: blink 1s linear infinite;
      }

      #battery.warning {
          color: #f9e2af;
      }

      #pulseaudio.muted {
          color: #585b70;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #f38ba8;
      }

      @keyframes blink {
          to { color: #1e1e2e; background-color: #f38ba8; }
      }
    '';
  };
}
