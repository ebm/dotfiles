{ config, ... }:

let
  domain = "neutral-server";
in
{
  sops.secrets.duckdns-token = { };

  services.duckdns = {
    enable = true;
    domains = [ domain ];

    tokenFile = "/run/credentials/duckdns.service/token";
  };

  systemd.services.duckdns.serviceConfig.LoadCredential = [
    "token:${config.sops.secrets.duckdns-token.path}"
  ];
}
