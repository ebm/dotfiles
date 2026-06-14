{ pkgs, ... }:

{
  imports = [
    ../common/home-common.nix
    ../../modules/sway
    ../../modules/waybar.nix
    ../../modules/foot.nix
    ../../modules/screenshots
  ];

  mine.sway.laptop = true;
  mine.zsh.laptop = true;

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 16;
  };
}
