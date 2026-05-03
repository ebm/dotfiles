# How to downgrade nvidia drivers back to 580.159.03

### Install requisite packages
```bash
#pacman -Q linux linux-headers
sudo pacman -S downgrade
sudo downgrade nvidia-open-dkms nvidia-utils lib32-nvidia-utils opencl-nvidia lib32-opencl-nvidia nvidia-settings libxnvctrl
```
Add to IgnorePkg.

### Check status
```bash
dkms status
```
If output is "added" and not "installed", run

```bash
sudo dkms autoinstall
```

### Latest available version on CachyOS as of 05/03/2026
```
580.119.02
```
