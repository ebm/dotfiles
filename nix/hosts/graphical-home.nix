{ pkgs, ... }:

{
  imports = [
    ../modules/sway
    ../modules/waybar
    ../modules/foot.nix
    ../modules/fuzzel.nix
    ../modules/screenshots
    ../modules/intellij.nix
    ../modules/librewolf.nix
    ../modules/pulsemixer.nix
    ../modules/graphical-packages.nix
  ];

  # Manages defaults
  xdg.mimeApps.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 16;
  };
}
