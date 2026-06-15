{ ... }:

{
  imports = [
    ../home-common.nix
    ../graphical-home.nix
  ];

  mine.sway.laptop = true;
  mine.zsh.laptop = true;
}
