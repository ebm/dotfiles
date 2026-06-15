{ pkgs, ... }:

{
  imports = [
    ../modules/sway
    ../modules/waybar
    ../modules/foot.nix
    ../modules/screenshots
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 16;
  };
}
