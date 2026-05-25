#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

# shellcheck source=install-common.sh
source ./install-common.sh

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $0 <profile>

Profiles:
  --laptop    Full Arch Linux setup for laptop  (pacman + sway-laptop + dotfiles)
  --desktop   Full Arch Linux setup for desktop (pacman + sway-desktop + dotfiles)
  --minimal   OS-agnostic dev tools via git/binary/npm + dotfiles (no GUI stack)

Re-running is safe — already-installed tools are skipped:
  - pacman/paru packages:  skipped via --needed
  - GitHub binaries:       skipped if binary already exists in ~/.local/bin
  - npm globals:           skipped if already in ~/.local npm prefix
  - zsh plugins:           skipped if already at the pinned ref (bump ref to update)
EOF
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
PROFILE=""
for arg in "$@"; do
    case "$arg" in
        --laptop)  PROFILE=laptop  ;;
        --desktop) PROFILE=desktop ;;
        --minimal) PROFILE=minimal ;;
        --help|-h) usage; exit 0   ;;
        *) error "Unknown flag: $arg"; echo; usage; exit 1 ;;
    esac
done

if [[ -z "$PROFILE" ]]; then
    usage
    exit 1
fi

info "Profile: $PROFILE"
info "Hostname: $(hostname)"
echo

# ---------------------------------------------------------------------------
# Arch profiles (laptop / desktop)
# ---------------------------------------------------------------------------
if [[ "$PROFILE" == laptop || "$PROFILE" == desktop ]]; then
    need_cmd sudo
    need_cmd git

    # 1. System packages
    install_pacman_packages packages.txt

    need_cmd stow
    ensure_dirs

    # 2. Stow dotfiles — shared + machine-specific
    COMMON_PACKAGES=(nvim zsh foot-config sway-common intellij waybar)

    if [[ "$PROFILE" == laptop ]]; then
        MACHINE_PACKAGES=(sway-laptop)
    else
        MACHINE_PACKAGES=(sway-desktop)
    fi

    OPTIONAL_PACKAGES=(mako btop mpv scripts)

    for pkg in "${COMMON_PACKAGES[@]}";  do stow_package "$pkg"; done
    for pkg in "${MACHINE_PACKAGES[@]}"; do stow_package "$pkg"; done
    for pkg in "${OPTIONAL_PACKAGES[@]}"; do [[ -d "$pkg" ]] && stow_package "$pkg"; done

    # 3. Zsh plugins
    install_zsh_plugins

    # 4. Laptop-only: verify expected display output exists
    if [[ "$PROFILE" == laptop ]] && pgrep -x sway >/dev/null 2>&1; then
        if ! swaymsg -t get_outputs | grep -q '"name": "eDP-1"'; then
            warn "Laptop config assumes display 'eDP-1' but that output wasn't found."
            warn "Check actual output name with: swaymsg -t get_outputs"
            warn "Then update sway-laptop/.config/sway/config.d/50-machine.conf accordingly."
        fi
    fi

    ok "$PROFILE install complete."
fi

# ---------------------------------------------------------------------------
# Minimal profile — OS-agnostic, no GUI stack
# ---------------------------------------------------------------------------
if [[ "$PROFILE" == minimal ]]; then
    need_cmd git
    need_cmd curl

    ensure_dirs
    install_stow_if_missing

    # 1. node/npm — uses existing install if present, otherwise downloads
    #    the latest LTS tarball directly from nodejs.org (no package manager needed)
    ensure_node

    # 2. npm globals
    install_npm_global @anthropic-ai/claude-code
    install_npm_global tree-sitter-cli

    # 3. GitHub binary releases
    install_github_binary \
        "neovim" \
        "neovim/neovim" \
        "nvim-linux-x86_64\.tar\.gz\"" \
        "nvim"

    install_github_binary \
        "ripgrep" \
        "BurntSushi/ripgrep" \
        "x86_64-unknown-linux-musl\.tar\.gz\"" \
        "rg"

    install_github_binary \
        "fzf" \
        "junegunn/fzf" \
        "linux_amd64\.tar\.gz\"" \
        "fzf"

    # 4. Stow dotfiles (only the OS-agnostic ones)
    MINIMAL_PACKAGES=(nvim zsh)
    for pkg in "${MINIMAL_PACKAGES[@]}"; do stow_package "$pkg"; done

    # 5. Zsh plugins
    install_zsh_plugins

    ok "Minimal install complete."
    echo
    info "Binaries installed to ~/.local/bin — make sure it is on your PATH."
fi

echo
