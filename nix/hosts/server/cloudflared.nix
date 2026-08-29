{ config, ... }:

let
  domain = "neutral.one";

  tunnelId = "b5303284-820f-4916-b11c-1e871fc57fcb";
in
{
  sops.secrets.cloudflared-tunnel = { };

  services.cloudflared = {
    enable = true;

    tunnels.${tunnelId} = {
      credentialsFile = "/run/credentials/cloudflared-tunnel-${tunnelId}.service/tunnel.json";

      ingress = {
        "${domain}" = "http://127.0.0.1:8080";
        "www.${domain}" = "http://127.0.0.1:8080";

        "app.${domain}" = "http://127.0.0.1:3000";

      };

      default = "http_status:404";
    };
  };

  systemd.services."cloudflared-tunnel-${tunnelId}".serviceConfig.LoadCredential = [
    "tunnel.json:${config.sops.secrets.cloudflared-tunnel.path}"
  ];

}
