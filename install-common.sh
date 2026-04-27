#!/usr/bin/env bash
# Shared functions for install scripts. Sourced, not run directly.

# Colored output
info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m  %s\n' "$*"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }
ok()    { printf '\033[1;32m[OK]\033[0m    %s\n' "$*"; }

# Confirm a destructive action
confirm() {
    local prompt="$1"
    read -rp "$prompt [y/N] " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Check that a command exists
need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        error "Required command not found: $1"
        return 1
    fi
}

# Install official repo packages from a file, skipping comments and blanks
install_pacman_packages() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        warn "Package file not found: $file (skipping)"
        return 0
    fi
    info "Installing pacman packages from $file..."
    grep -vE '^(#|$)' "$file" | sudo pacman -S --needed --noconfirm -
}

# Install AUR packages from a file, skipping comments and blanks
install_aur_packages() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        warn "AUR package file not found: $file (skipping)"
        return 0
    fi
    if ! command -v paru >/dev/null 2>&1; then
        warn "paru not found; skipping AUR packages"
        return 0
    fi
    info "Installing AUR packages from $file..."
    grep -vE '^(#|$)' "$file" | paru -S --needed --noconfirm -
}

# Stow a package, with helpful errors on conflicts
stow_package() {
    local pkg="$1"
    if [[ ! -d "$pkg" ]]; then
        warn "Stow package not found: $pkg (skipping)"
        return 0
    fi
    info "Stowing $pkg..."
    if ! stow -R "$pkg" 2>&1; then
        error "Stow failed for $pkg. Check for conflicts in target paths."
        return 1
    fi
}

# Ensure shared directories exist as real dirs before stow,
# so stow uses per-file symlinks instead of folding the whole directory.
ensure_dirs() {
    mkdir -p ~/.local/bin
    mkdir -p ~/.local/share
    mkdir -p ~/.config
}

# Install a system file (drop-in) into /etc/ with proper ownership
install_system_file() {
    local src="$1"
    local dst="$2"
    local mode="${3:-644}"
    if [[ ! -f "$src" ]]; then
        warn "Source file not found: $src (skipping)"
        return 0
    fi
    info "Installing $src -> $dst"
    sudo install -m "$mode" -D "$src" "$dst"
}
