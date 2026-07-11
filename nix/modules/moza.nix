{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.boxflat ];
  services.udev.packages = [ pkgs.boxflat ];
}
