# Transfer Configs Between Computers

### Generate ssh key:
```bash
ssh-keygen -t ed25519 -C "ebmarantz@gmail.com"
```
Use default folder (~/.ssh).
Choose a password.

### Add ssh key to github:
```bash
cat ~/.ssh/id_ed25519.pub | wl-copy
```
Ignore wl-copy if not installed and copy manually.
Navigate to <https://github.com/settings/keys> and paste public key in. Name accordingly.

### Run Install Script
If on laptop, run this command
```bash
./install-laptop.sh
```

If on desktop, run this command
```bash
./install-desktop.sh
```

### Final steps
Restart computer. :D
