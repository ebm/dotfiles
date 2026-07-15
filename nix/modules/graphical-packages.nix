{ pkgs, ... }: {
  home.packages = with pkgs; [
    discord
    imv
    mpv
    gimp
    jetbrains.idea-oss
    slurp
    wl-clipboard
    pulsemixer
  ];
}
