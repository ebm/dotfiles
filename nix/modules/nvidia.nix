{ config, ... }:

{
  # NVIDIA GA102 (RTX 3080-class, Ampere) dedicated GPU.

  # Enable OpenGL / Vulkan.
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Load the proprietary NVIDIA driver.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Required for Wayland (Sway) — enables DRM kernel mode setting.
    modesetting.enable = true;

    # Use the open-source kernel modules (recommended for Turing and newer).
    open = true;

    # Desktop is always plugged in; leave suspend/resume power management off.
    powerManagement.enable = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
