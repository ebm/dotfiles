{ pkgs, ... }:
let
  mkScript =
    name: libraries:
    pkgs.writers.writePython3Bin name {
      inherit libraries;
      flakeIgnore = [ "E501" ];
    } (builtins.readFile ./${name}.py);
in
{
  home.packages = [
    (mkScript "screenshot" (with pkgs.python3Packages; [ rapidocr ]))
    (mkScript "saved-screenshots" [ ])
  ];
}
