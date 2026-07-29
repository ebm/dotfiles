{
  pkgs,
  config,
  lib,
  ...
}:

let
  wallpapers = ./wallpapers;
  stateDir = "${config.xdg.stateHome}/wallpaper";
  index = "${stateDir}/index";
in
{
  # Symlink to the wallpaper in use. Sway's `output bg` and swaylock point at it,
  # so a reload or a lock follows the cycle instead of snapping back to the seed.
  options.mine.wallpaperLink = lib.mkOption {
    type = lib.types.str;
    readOnly = true;
    default = "${stateDir}/current";
  };

  config = {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "wallpaper";
        runtimeInputs = with pkgs; [
          sway
          coreutils
        ];
        text = ''
          papers=(${wallpapers}/*)
          count=''${#papers[@]}
          current=$(cat ${index} || echo -1)
          next=$(( (current + 1) % count ))

          echo "$next" >${index}
          ln -sf "''${papers[next]}" ${config.mine.wallpaperLink}
          swaymsg output '*' bg "''${papers[next]}" fill
        '';
      })
    ];

    # Seed the link so the first sway launch has something to show.
    home.activation.wallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "${config.mine.wallpaperLink}" ]; then
        run mkdir -p ${stateDir}
        run ln -sf ${wallpapers}/chill.jpg "${config.mine.wallpaperLink}"
      fi
    '';
  };
}
