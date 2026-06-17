{
  pkgs,
  lib,
  host,
  ...
}:
{

  options.mine.host = lib.mkOption {
    type = lib.types.enum [
      "desktop"
      "laptop"
      "server"
    ];
  };

  config = {
    mine.host = host;
    networking.hostName = "ebm-${host}";

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use latest kernel.
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelParams = [ "quiet" ];
    boot.initrd.verbose = false;

    # Configure network connections interactively with nmcli or nmtui.
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/New_York";

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.ethan = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];

    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = with pkgs; [
      git
      waybar
      unzip
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # Copy the NixOS configuration file and link it from the resulting system
    # (/run/current-system/configuration.nix). This is useful in case you
    # accidentally delete configuration.nix.
    # system.copySystemConfiguration = true;

  };
}
