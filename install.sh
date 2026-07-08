#!/usr/bin/env bash

set -euo pipefail

read -rp "Host: " HOST
read -rp "Username: " USERNAME

DOTFILES="$HOME/dotfiles"
FLAKE="$DOTFILES/nix"

sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount "$FLAKE/hosts/$HOST/disko-config.nix"

sudo nixos-generate-config --no-filesystems --root /mnt --dir "$FLAKE/hosts/$HOST"

sudo nixos-install --flake "$FLAKE#$HOST"

sudo nixos-enter --root /mnt --command "passwd $USERNAME"

sudo cp -r "$DOTFILES" "/mnt/home/$USERNAME/dotfiles"
sudo nixos-enter --root /mnt --command "chown -R $USERNAME:users /home/$USERNAME/dotfiles"

sudo reboot
