{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writers.writePython3Bin "screenshot" {
      libraries = with pkgs.python3Packages; [
        rapidocr
      ];
      flakeIgnore = [ "E501" ];
    } (builtins.readFile ./screenshot))
  ];
}
