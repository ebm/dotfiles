{ ... }:

{
  programs.librewolf = {
    enable = true;
    settings = { };
    policies = {
      ExtensionSettings = {
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "normal_installed";
        };
        # Dark Reader
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "normal_installed";
        };
        # Bitwarden Password Manager
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "normal_installed";
        };
        # Ctrl+Number to switch tabs
        "{84601290-bec9-494a-b11c-1baa897a9683}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ctrl-number-to-switch-tabs/latest.xpi";
          installation_mode = "normal_installed";
        };
        # Claude.ai Freeze Fix on LibreWolf
        "{0f914ee6-8712-47f8-9dc7-847baa59db3f}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/claude-ai-freeze-fix-librewolf/latest.xpi";
          installation_mode = "normal_installed";
        };
      };
    };
  };
}
