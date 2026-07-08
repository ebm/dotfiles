# NixOS Reinstall Runbook

Wipes `/dev/nvme0n1` and installs NixOS from this flake using disko.

## Prerequisites

- `flake.nix` has `disko` as an input and `inputs.disko.nixosModules.disko` in the laptop module list.
- NixOS 26.05 installer USB.
- A second device (phone, other laptop) holding a copy of this repo — needed to receive it on the installer. Alternatively, put the repo on a USB stick.

## Transfer dotfiles to installer

Stage `~/dotfiles` on your second device beforehand (any method).

Boot the installer USB and get on wifi with `nmtui`.

On the second device (sender):
```bash
croc send ~/dotfiles
```

On the installer (receiver), using the code croc printed on the sender:
```bash
cd /tmp
nix-shell -p croc
croc <code>
```

Files land in `/tmp/dotfiles/`.

USB-stick alternative: mount the stick and `cp -r /mnt-usb/dotfiles /tmp/`.

## Wipe and format the disk

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount /tmp/dotfiles/nix/hosts/laptop/disko-config.nix
```

Prompts for a LUKS passphrase. Ends with the new filesystems mounted at `/mnt`.

## Generate fresh hardware-configuration.nix

Writes into the flake so `nixos-install` picks it up:
```bash
sudo nixos-generate-config --no-filesystems --root /mnt --dir /tmp/dotfiles/nix/hosts/laptop
```

## Install

```bash
sudo nixos-install --flake /tmp/dotfiles/nix#laptop
```

Prompts for a root password at the end.

## Set user password

```bash
sudo nixos-enter --root /mnt --command "passwd ethan"
```

## Reboot

```bash
sudo reboot
```

---

# Post-install: add SSH key for GitHub

### Generate SSH key
```bash
ssh-keygen -t ed25519 -C "ebmarantz@gmail.com"
```
Use default folder (`~/.ssh`). Choose a password.

### Add SSH key to GitHub
```bash
cat ~/.ssh/id_ed25519.pub | wl-copy
```
Ignore `wl-copy` if not installed and copy manually. Navigate to <https://github.com/settings/keys> and paste the public key. Name accordingly.

### Re-clone dotfiles with SSH remote
```bash
cd ~
rm -rf dotfiles     # if you copied the transferred copy in
git clone git@github.com:ebm/dotfiles.git
cd ~/dotfiles/
```
