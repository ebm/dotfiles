{ ... }:

let
  mediaDir = "/srv/media";
in
{
  users.groups.media = { };

  users.users.jellyfin.extraGroups = [
    "media"
    "render"
  ];
  users.users.ethan.extraGroups = [ "media" ];

  systemd.tmpfiles.rules = [
    "d ${mediaDir} 2775 ethan media -"
    "d ${mediaDir}/movies 2775 ethan media -"
    "d ${mediaDir}/shows 2775 ethan media -"
  ];

  hardware.graphics.enable = true;

  services.jellyfin = {
    enable = true;

    openFirewall = false;

    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };

    forceEncodingConfig = true;

    transcoding = {
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        vp9 = true;
        av1 = true;
      };

      enableHardwareEncoding = true;
      hardwareEncodingCodecs = {
        hevc = true;
        av1 = true;
      };
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8096 ];
}
