{ config, ... }:

{
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Required for Wayland (Sway) — enables DRM kernel mode setting.
    modesetting.enable = true;

    open = true;

    powerManagement.enable = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
