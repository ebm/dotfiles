{ pkgs, ... }:

let
  projectDir = "/home/ethan/obsidia/nexaone-core";

  compose = pkgs.writeShellScript "obsidia-compose" ''
    exec ${pkgs.podman-compose}/bin/podman-compose \
      --env-file ${projectDir}/.staging.env \
      -f ${projectDir}/docker-compose.yml \
      -f ${projectDir}/docker-compose.staging.yml \
      -f ${projectDir}/docker-compose.host.yml \
      "$@"
  '';
in
{
  users.users.ethan.linger = true;

  systemd.user.services.obsidia = {
    description = "Obsidia stack (rootless podman compose)";
    wantedBy = [ "default.target" ];

    path = [ pkgs.podman ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = projectDir;
      ExecStart = "${compose} up -d";
      ExecStop = "${compose} down";
      TimeoutStartSec = "900";
    };
  };
}
