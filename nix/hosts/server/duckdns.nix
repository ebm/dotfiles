{ ... }:

let
  domain = "neutral-server";
in
{
  services.duckdns = {
    enable = true;
    domains = [ domain ];

    tokenFile = "/var/lib/duckdns/token";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/duckdns 0700 root root -"
  ];
}
