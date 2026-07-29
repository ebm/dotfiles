{ pkgs, ... }: {
  home.packages = with pkgs; [
    pulsemixer
  ];

  xdg.desktopEntries.pulsemixer = {
    name = "pulsemixer";
    comment = "CLI audio control";
    exec = "pulsemixer";
    icon = "audio-volume-high";
    terminal = true;
    categories = [
      "AudioVideo"
      "Audio"
      "Mixer"
    ];
  };
}
