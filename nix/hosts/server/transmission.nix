{ pkgs, ... }:
let
  mediaDir = "/srv/media";
  rpcPort = 9091;
in
{
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;

    credentialsFile = "/var/lib/secrets/transmission/settings.json";

    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-port = rpcPort;
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
      rpc-authentication-required = true;

      umask = 2;

      # 2 = require encrypted peer connections (0 off, 1 prefer).
      encryption = 2;

      peer-port = 51413;
      port-forwarding-enabled = false;

      download-dir = "${mediaDir}/downloads";
      incomplete-dir = "${mediaDir}/incomplete";
      incomplete-dir-enabled = true;
    };
  };

  users.users.transmission.extraGroups = [ "media" ];

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ rpcPort ];

  systemd.tmpfiles.rules = [
    "d ${mediaDir}/downloads 2775 ethan media -"
    "d ${mediaDir}/incomplete 2775 ethan media -"
  ];
}
