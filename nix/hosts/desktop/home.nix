{ ... }:

{
  imports = [
    ../home-common.nix
    ../graphical-home.nix
  ];

  mine.sway.desktop = true;
  mine.zsh.desktop = true;
}
