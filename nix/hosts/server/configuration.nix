{ ... }:

{
  imports = [
    ../configuration-common.nix
    ./hardware-configuration.nix
    ./disko-config.nix
    ./minecraft-server.nix
    ./duckdns.nix
    ./cloudflared.nix
    ./obsidia.nix
    ./jellyfin.nix
    #./transmission.nix
  ];

  system.stateVersion = "26.05";
}
