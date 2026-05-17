#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

# shellcheck source=install-common.sh
source ./install-common.sh

info "Starting laptop install..."
info "Hostname: $(hostname)"

need_cmd sudo
need_cmd git

# 1. Packages
install_pacman_packages packages.txt

need_cmd stow
ensure_dirs

# 2. Stow user dotfiles
LAPTOP_PACKAGES=(
    nvim
    zsh
    foot-config
    sway-common
    sway-laptop
    intellij
    waybar
)

OPTIONAL_PACKAGES=(
    mako
    btop
    mpv
    scripts
)

for pkg in "${LAPTOP_PACKAGES[@]}"; do
    stow_package "$pkg"
done

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    [[ -d "$pkg" ]] && stow_package "$pkg"
done

# 3. System config: install logind drop-in for lid switch behavior
#install_system_file \
#    system/logind/50-lid.conf \
#    /etc/systemd/logind.conf.d/50-lid.conf \
#    644

# 4. Restart services to pick up new config

#info "Reloading systemd to detect new drop-ins..."
#sudo systemctl daemon-reload
#
#info "Restarting systemd-logind to apply lid switch settings..."
#sudo systemctl restart systemd-logind

# 5. Verify the laptop's display output exists where expected
if pgrep -x sway >/dev/null 2>&1; then
    if ! swaymsg -t get_outputs | grep -q '"name": "eDP-1"'; then
        warn "Laptop config assumes display 'eDP-1' but that output wasn't found."
        warn "Check actual output name with: swaymsg -t get_outputs"
        warn "Then update sway-laptop/.config/sway/config.d/50-machine.conf accordingly."
    fi
fi

ok "Laptop install complete."
echo
