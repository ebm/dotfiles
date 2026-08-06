{ pkgs, ... }: {
  home.packages = with pkgs; [
    discord
    mpv
    gimp
    jetbrains.idea
    slurp
    wl-clipboard
    firefox
  ];
}
