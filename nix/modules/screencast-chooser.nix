{ lib, pkgs, ... }:
let
  chooser = pkgs.writeShellApplication {
    name = "screencast-chooser";
    runtimeInputs = with pkgs; [
      fuzzel
      jq
      lswt
      sway
    ];
    text = ''
      {
        swaymsg -t get_outputs -r |
          jq -r '.[] | select(.active) | "Screen: \(.name)\tMonitor: \(.name)"'
        lswt -j |
          jq -r '.toplevels[] | select(.identifier != null) | "\(.["app-id"]) — \(.title)\tWindow: \(.identifier)"'
      } | fuzzel --dmenu --only-match --with-nth=1 --accept-nth=2 --prompt='Share: '
    '';
  };
in
{
  xdg.portal.wlr = {
    enable = true;
    settings.screencast = {
      chooser_type = "simple";
      chooser_cmd = lib.getExe chooser;
    };
  };
}
