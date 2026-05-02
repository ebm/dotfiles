# How to connect to WIFI using linux

## For a TUI interface:

### Open the TUI
```bash
nmtui
```

## For CLI:

### Display available networks
```bash
nmcli device wifi rescan
nmcli device wifi list
```

### Connect to WIFI Network

#### Without Password Prompt
```bash
nmcli device wifi connect <SSID> password <PASSWORD> ifname <INTERFACE>
```

#### With password Prompt
```bash
nmcli device wifi connect <SSID> --ask ifname <INTERFACE>
```


### Showing Saved Connections
```bash
nmcli connection show
```

### Reconnecting to Saved Connection
```bash
nmcli connection up <CONNECTION_NAME>
```

### Disconnecting
```bash
nmcli device disconnect <INTERFACE>
```

### Deleting Network
```bash
nmcli connection delete <NETWORK_NAME>
```
