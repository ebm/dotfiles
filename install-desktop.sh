#!/usr/bin/env bash
set -euo pipefail

# Move to the script's directory so all paths are relative to the repo
cd "$(dirname "$(readlink -f "$0")")"

# shellcheck source=install-common.sh
source ./install-common.sh

info "Starting desktop install..."
info "Hostname: $(hostname)"

# Sanity check
need_cmd sudo
need_cmd git

# 1. Packages
install_pacman_packages packages.txt

# 2. Ensure stow is available now that pacman ran
need_cmd stow

# 3. Make sure shared directories exist before stow
ensure_dirs

# 4. Stow user dotfiles
DESKTOP_PACKAGES=(
    nvim
    zsh
    foot-config
    sway-common
    sway-desktop
    intellij
    waybar
)

# Optional packages: stow only if directory exists
OPTIONAL_PACKAGES=(
    mako
    btop
    mpv
    scripts
)

for pkg in "${DESKTOP_PACKAGES[@]}"; do
    stow_package "$pkg"
done

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    [[ -d "$pkg" ]] && stow_package "$pkg"
done

ok "Desktop install complete."
echo
