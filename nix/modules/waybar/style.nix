{ ... }: {
  programs.waybar = {
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
                border-radius: 0;
                margin: 8px;
            }

            #workspaces {
                background: #313244;
                border-radius: 10px;
                margin: 4px 4px;
                padding: 0 4px;
            }

            #workspaces button {
                padding: 0 8px;
                color: #a6adc8;
                background: transparent;
                border-radius: 8px;
            }

            #workspaces button:hover {
                background: #45475a;
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

            #mode,
            #scratchpad {
                background: #313244;
                border-radius: 10px;
                margin: 4px 4px;
                padding: 0 10px;
            }

            #cpu,
            #temperature,
            #custom-gpu-usage,
            #custom-gpu-temp,
            #disk,
            #memory,
            #pulseaudio,
            #network,
            #battery,
            #clock,
            #tray {
                background: #313244;
                color: #cdd6f4;
                padding: 0 10px;
                border-radius: 10px;
                margin: 4px 4px;
            }

            #cpu { border-radius: 10px 0 0 10px; margin: 4px 0 4px 4px; }
            #temperature { border-radius: 0 10px 10px 0; margin: 4px 4px 4px 0; }
            #custom-gpu-usage { border-radius: 10px 0 0 10px; margin: 4px 0 4px 4px; }
            #custom-gpu-temp { border-radius: 0 10px 10px 0; margin: 4px 4px 4px 0; }

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
