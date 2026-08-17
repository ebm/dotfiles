{ pkgs, ... }:

let
  # Root of the extracted ServerPackCreator pack. Bump this when updating the pack.
  serverDir = "/opt/minecraft/prominence-updated";

  # Prominence II (Hasturian Era) is Minecraft 1.20.1 / Fabric, which wants Java 17
  # (RECOMMENDED_JAVA_VERSION in the pack's variables.txt).
  jdk = pkgs.jdk17;

  # start.sh sources variables.txt, so environment variables cannot override it.
  # Rewrite the handful of settings that are wrong for a systemd service, and
  # accept the EULA non-interactively (start.sh otherwise prompts on stdin).
  # server.properties is deliberately left alone; it's managed by hand.
  prepare = pkgs.writeShellScript "prominence-prepare" ''
    set -eu
    cd ${serverDir}

    if [ ! -s eula.txt ]; then
      printf '%s\n' \
        '#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).' \
        'eula=true' > eula.txt
    fi

    tmp=$(mktemp)
    ${pkgs.gnused}/bin/sed \
      -e 's/^WAIT_FOR_USER_INPUT=.*/WAIT_FOR_USER_INPUT=false/' \
      -e 's/^RESTART=.*/RESTART=false/' \
      -e 's/^SKIP_JAVA_CHECK=.*/SKIP_JAVA_CHECK=true/' \
      -e 's/^JAVA_ARGS=.*/JAVA_ARGS="-Xmx8G -Xms4G"/' \
      variables.txt > "$tmp"
    ${pkgs.coreutils}/bin/install -m 0644 "$tmp" variables.txt
    rm -f "$tmp"
  '';
in
{
  environment.systemPackages = [ jdk ];

  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
    home = serverDir;
    createHome = true;
    homeMode = "770";
  };
  users.groups.minecraft = { };

  users.users.ethan.extraGroups = [ "minecraft" ];

  # The pack was unzipped as root; the service user needs to own it (start.sh
  # writes the world, logs, downloaded launcher jar and libraries in-tree).
  systemd.tmpfiles.rules = [
    # Mode is "-" on purpose: this is ~1 GB of mod jars, and forcing 0770 on
    # every file would make them all executable and re-chmod the tree each boot.
    "Z ${serverDir} - minecraft minecraft -"
  ];

  systemd.services.prominence = {
    description = "Prominence II (Hasturian Era) Minecraft Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    restartIfChanged = false;

    # start.sh shells out to these; it also curls the Fabric launcher on first run.
    path = [
      jdk
      pkgs.bash
      pkgs.coreutils
      pkgs.gawk
      pkgs.curl
    ];

    serviceConfig = {
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = serverDir;
      ExecStartPre = "${prepare}";
      ExecStart = "${pkgs.bash}/bin/bash ${serverDir}/start.sh";
      Restart = "on-failure";
      RestartSec = "30s";

      # Saving 400+ mods' worth of chunks takes a while; don't SIGKILL mid-save.
      TimeoutStopSec = "120s";
      StandardInput = "null";

      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ serverDir ];
      NoNewPrivileges = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      LockPersonality = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 25565 ];
}
