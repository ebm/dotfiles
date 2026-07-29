{ pkgs, ... }: {
  home.packages = with pkgs; [
    discord
    mpv
    gimp
    jetbrains.idea-oss
    slurp
    wl-clipboard
    firefox
  ];
}
