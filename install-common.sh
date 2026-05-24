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
    mkdir -p ~/.zsh/plugins
}

# Clone a zsh plugin to ~/.zsh/plugins/<name> and pin to a git ref.
# Skips if the repo already exists at the correct ref.
# Bump the ref here to update a plugin.
install_zsh_plugin() {
    local name="$1"
    local url="$2"
    local ref="$3"
    local dir="$HOME/.zsh/plugins/$name"

    if [[ -d "$dir/.git" ]]; then
        local current
        current=$(git -C "$dir" describe --tags --exact-match 2>/dev/null \
                  || git -C "$dir" rev-parse HEAD 2>/dev/null)
        if [[ "$current" == "$ref" ]]; then
            ok "$name already at $ref — skipping"
            return 0
        fi
        info "Updating $name to $ref..."
        git -C "$dir" fetch --quiet --tags origin
    else
        info "Cloning $name..."
        git clone --quiet "$url" "$dir"
    fi

    git -C "$dir" checkout --quiet "$ref"
    ok "$name → $ref"
}

# Install all zsh plugins (shared across profiles)
install_zsh_plugins() {
    info "Installing zsh plugins..."
    install_zsh_plugin powerlevel10k                  https://github.com/romkatv/powerlevel10k                  v1.20.0
    install_zsh_plugin zsh-autosuggestions            https://github.com/zsh-users/zsh-autosuggestions          v0.7.1
    install_zsh_plugin zsh-history-substring-search   https://github.com/zsh-users/zsh-history-substring-search v1.1.0
    install_zsh_plugin zsh-syntax-highlighting        https://github.com/zsh-users/zsh-syntax-highlighting      0.8.0
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

# --- Minimal / OS-agnostic helpers ---

# Detect the system package manager
detect_package_manager() {
    if   command -v pacman >/dev/null 2>&1; then echo pacman
    elif command -v apt    >/dev/null 2>&1; then echo apt
    elif command -v dnf    >/dev/null 2>&1; then echo dnf
    elif command -v brew   >/dev/null 2>&1; then echo brew
    else echo unknown
    fi
}

# Install stow via the detected package manager if it isn't already present
install_stow_if_missing() {
    if command -v stow >/dev/null 2>&1; then
        ok "stow already installed"
        return 0
    fi
    local pm; pm=$(detect_package_manager)
    info "Installing stow via $pm..."
    case "$pm" in
        pacman) sudo pacman -S --needed --noconfirm stow ;;
        apt)    sudo apt-get install -y stow ;;
        dnf)    sudo dnf install -y stow ;;
        brew)   brew install stow ;;
        *)
            error "Unknown package manager — install stow manually then re-run."
            return 1
            ;;
    esac
}

# Ensure node and npm are available.
# If already on PATH (e.g. via pacman on Arch), uses them as-is.
# Otherwise downloads the latest LTS tarball from nodejs.org and extracts
# it into ~/.local — npm then lives at ~/.local/bin and defaults to
# ~/.local as its global prefix, so npm install -g needs no extra config.
ensure_node() {
    if command -v npm >/dev/null 2>&1; then
        ok "npm already available ($(npm --version))"
        return 0
    fi

    need_cmd curl

    info "Fetching latest Node.js LTS version..."
    local version
    version=$(curl -sfL https://nodejs.org/dist/latest-lts/SHASUMS256.txt \
        | grep -oP 'node-v[\d.]+(?=-linux)' | head -1)

    [[ -n "$version" ]] || { error "Could not determine latest Node LTS version."; return 1; }

    local arch
    case "$(uname -m)" in
        x86_64)  arch=x64   ;;
        aarch64) arch=arm64 ;;
        armv7l)  arch=armv7l ;;
        *)       error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    local tmpdir; tmpdir=$(mktemp -d)
    local filename="${version}-linux-${arch}.tar.xz"

    info "Downloading Node.js ${version} (${arch})..."
    curl -sfL --progress-bar "https://nodejs.org/dist/latest-lts/${filename}" \
        -o "$tmpdir/$filename"

    # The tarball is structured as a prefix tree (bin/, lib/, ...) —
    # strip the top-level versioned directory and extract straight into ~/.local
    tar -xJf "$tmpdir/$filename" --strip-components=1 -C "$HOME/.local"
    rm -rf "$tmpdir"

    ok "Node.js ${version} → ~/.local/bin"
}

# Install a global npm package into ~/.local so no sudo is needed,
# regardless of whether npm came from a system package manager or our tarball.
# Skips if the package is already installed.
install_npm_global() {
    local pkg="$1"
    if npm list -g --prefix "$HOME/.local" --depth=0 2>/dev/null | grep -q "$pkg"; then
        ok "$pkg already installed — skipping"
        return 0
    fi
    info "Installing npm package: $pkg..."
    npm install -g --prefix "$HOME/.local" "$pkg"
    ok "$pkg → ~/.local/bin"
}

# Download the latest GitHub release binary and place it in ~/.local/bin.
# Skips if the binary already exists. Remove the binary to force a reinstall.
#
# Arguments:
#   name           Human-readable name, e.g. "neovim"
#   repo           GitHub repo slug, e.g. "neovim/neovim"
#   asset_pattern  Extended-regex matched against asset download URLs, e.g. "linux-x86_64\.appimage$"
#   binary_name    Name of the binary inside the archive (or final symlink name for AppImages)
#   install_dir    Target directory (default: ~/.local/bin)
install_github_binary() {
    local name="$1"
    local repo="$2"
    local asset_pattern="$3"
    local binary_name="$4"
    local install_dir="${5:-$HOME/.local/bin}"

    if [[ -x "$install_dir/$binary_name" ]]; then
        ok "$name already installed — skipping"
        return 0
    fi

    need_cmd curl

    info "Fetching latest $name release..."
    local release_json
    release_json=$(curl -sfL "https://api.github.com/repos/$repo/releases/latest")

    local latest_tag
    latest_tag=$(printf '%s' "$release_json" | grep '"tag_name"' | head -1 | cut -d'"' -f4)

    local asset_url
    asset_url=$(printf '%s' "$release_json" \
        | grep '"browser_download_url"' \
        | grep -iE "$asset_pattern" \
        | head -1 \
        | cut -d'"' -f4)

    if [[ -z "$asset_url" ]]; then
        warn "No asset matching '$asset_pattern' found for $name $latest_tag — skipping"
        return 1
    fi

    local tmpdir; tmpdir=$(mktemp -d)
    local filename; filename=$(basename "$asset_url")

    info "Downloading $name $latest_tag..."
    curl -sfL --progress-bar "$asset_url" -o "$tmpdir/$filename"

    mkdir -p "$install_dir"

    case "$filename" in
        *.AppImage|*.appimage)
            install -m755 "$tmpdir/$filename" "$install_dir/$binary_name"
            ;;
        *.tar.gz|*.tgz)
            tar -xzf "$tmpdir/$filename" -C "$tmpdir"
            local bin; bin=$(find "$tmpdir" -type f -name "$binary_name" | head -1)
            if [[ -z "$bin" ]]; then
                warn "Binary '$binary_name' not found inside $filename"
                rm -rf "$tmpdir"; return 1
            fi
            install -m755 "$bin" "$install_dir/$binary_name"
            ;;
        *.tar.bz2|*.tbz|*.tbz2)
            tar -xjf "$tmpdir/$filename" -C "$tmpdir"
            local bin; bin=$(find "$tmpdir" -type f -name "$binary_name" | head -1)
            if [[ -z "$bin" ]]; then
                warn "Binary '$binary_name' not found inside $filename"
                rm -rf "$tmpdir"; return 1
            fi
            install -m755 "$bin" "$install_dir/$binary_name"
            ;;
        *.zip)
            unzip -q "$tmpdir/$filename" -d "$tmpdir"
            local bin; bin=$(find "$tmpdir" -type f -name "$binary_name" | head -1)
            if [[ -z "$bin" ]]; then
                warn "Binary '$binary_name' not found inside $filename"
                rm -rf "$tmpdir"; return 1
            fi
            install -m755 "$bin" "$install_dir/$binary_name"
            ;;
        *)
            warn "Unrecognised archive format: $filename"
            rm -rf "$tmpdir"; return 1
            ;;
    esac

    rm -rf "$tmpdir"
    ok "$name $latest_tag → $install_dir/$binary_name"
}
