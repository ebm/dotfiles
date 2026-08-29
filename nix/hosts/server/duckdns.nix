{ config, ... }:

let
  domain = "neutral-server";
in
{
  sops.secrets.duckdns-token = { };

  services.duckdns = {
    enable = true;
    domains = [ domain ];

    tokenFile = config.sops.secrets.duckdns-token.path;
  };
}
