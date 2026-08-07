{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.jdk8 ];

  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
    home = "/opt/minecraft/rlcraft";
    createHome = true;
    homeMode = "770";
  };
  users.groups.minecraft = {};

  users.users.ethan.extraGroups = [ "minecraft" ];

  systemd.services.rlcraft = {
    description = "RLCraft Minecraft Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    restartIfChanged = false;

    serviceConfig = {
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = "/opt/minecraft/rlcraft";
      ExecStart = "${pkgs.jdk8}/bin/java -Xmx6G -Xms2G -jar forge-server.jar nogui";
      Restart = "on-failure";
      RestartSec = "30s";

      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/opt/minecraft/rlcraft" ];
      NoNewPrivileges = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      LockPersonality = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 25565 ];
}
