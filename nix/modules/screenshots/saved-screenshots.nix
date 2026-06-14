{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writers.writePython3Bin "saved-screenshots" {
      flakeIgnore = [ "E501" ];
    } (builtins.readFile ./saved-screenshots))
  ];
}
