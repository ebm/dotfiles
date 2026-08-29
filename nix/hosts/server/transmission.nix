{
  config,
  lib,
  pkgs,
  ...
}:

# Transmission confined to a network namespace whose only route is a
# WireGuard tunnel to Proton.
#
# Two things below are not secret and have to be filled in by hand, from a
# WireGuard config generated at https://account.protonvpn.com/downloads
# (pick a P2P server, and enable NAT-PMP when generating it):
#
#   protonPublicKey   the `PublicKey` line from the [Peer] section
#   protonEndpoint    the `Endpoint` line from the [Peer] section
#
# The `PrivateKey` from the same config is secret and lives in sops as
# `proton-wireguard-key`. The assertion at the bottom fails the build while
# the placeholders are still in place, so a half-configured tunnel cannot be
# deployed silently.
#
# One thing to watch: the upstream module bind-mounts the host's /run into
# Transmission's chroot, so any resolver socket living there is reachable from
# inside the namespace. nsncd is the only one today and it is cut off below,
# but enabling services.resolved would silently add
# /run/systemd/resolve/io.systemd.Resolve as a second path past the tunnel.

let
  mediaDir = "/srv/media";
  namespace = "vpn";
  rpcPort = 9091;

  # `peers` below sets this as the peer's `name`, which is what the WireGuard
  # module derives the peer unit's name from. Without it the unit is named
  # after the escaped public key.
  peerName = "proton";

  placeholder = "REPLACE_ME";
  # Generated against US-MA#67; regenerate both lines together if the server
  # changes, since the key is per-server.
  protonPublicKey = "F4aiTD/LLylCVSoyO4pIxX8BuP6t0wS8tKHGAifWdFQ=";
  protonEndpoint = "79.127.160.129:51820";

  # From the Proton WireGuard config: `Address` and `DNS`. Proton hands out the
  # same 10.2.0.x addressing on every server, so these rarely need changing.
  vpnAddress = "10.2.0.2/32";
  vpnDns = "10.2.0.1";

  # Proton answers NAT-PMP on the tunnel gateway, which is also the resolver.
  vpnGateway = "10.2.0.1";

  # Proton grants port mappings for 60s at a time; renew comfortably inside it.
  portLifetime = 60;
  portRenewInterval = 45;
in
{
  sops.secrets.transmission-credentials = { };
  sops.secrets.proton-wireguard-key = { };

  # --------------------------------------------------------------------------
  # The namespace.
  #
  # This is the kill switch, and it is structural rather than a rule that has
  # to fire. A fresh netns contains a down `lo` and nothing else. When wg0 is
  # present it installs a default route; when it is not, the routing table is
  # empty and connect() returns ENETUNREACH. There is no host interface inside
  # the namespace to fall through to, so there is no leak to prevent.
  #
  # `ip netns add` is the one imperative step: nothing in nixpkgs models a
  # network namespace (only nixos-containers, internally). ExecStartPre tears
  # down any leftover namespace first so a crashed unit cannot wedge the start.
  # --------------------------------------------------------------------------
  systemd.services."netns@" = {
    description = "Network namespace %I";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "-${pkgs.iproute2}/bin/ip netns del %I";
      ExecStart = [
        "${pkgs.iproute2}/bin/ip netns add %I"
        # A new namespace's loopback starts down; Transmission's RPC listener
        # and the proxy that reaches it both need it up.
        "${pkgs.iproute2}/bin/ip -n %I link set lo up"
      ];
      ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
    };
  };

  # --------------------------------------------------------------------------
  # The tunnel.
  #
  # socketNamespace = null keeps the UDP socket in the init namespace, so
  # encrypted packets leave over the real NIC; interfaceNamespace moves the
  # wg0 device into `vpn`, so everything inside sees only the tunnel. This is
  # the upstream WireGuard netns design, and the NixOS module implements it
  # directly -- no `ip link set netns` by hand.
  #
  # allowedIPs = 0.0.0.0/0 becomes a default route *inside* the namespace, and
  # cannot loop back on itself because the socket is not in there with it.
  # There is no IPv6 address and no ::/0 route, so IPv6 has no path out at all.
  # --------------------------------------------------------------------------
  networking.wireguard.interfaces.wg0 = {
    ips = [ vpnAddress ];
    privateKeyFile = config.sops.secrets.proton-wireguard-key.path;

    socketNamespace = null;
    interfaceNamespace = namespace;

    peers = [
      {
        name = peerName;
        publicKey = protonPublicKey;
        endpoint = protonEndpoint;
        allowedIPs = [ "0.0.0.0/0" ];
        persistentKeepalive = 25;
      }
    ];
  };

  # The interface unit only creates wg0, moves it into the namespace and brings
  # it up. The peer unit -- generated from `peers` above, and ordered *after*
  # the interface unit -- is what installs the peer and the 0.0.0.0/0 route, so
  # both need the namespace.
  #
  # partOf as well as bindsTo: bindsTo alone stops these when the namespace goes
  # away but never brings them back, and a recreated namespace is empty, so the
  # device and route have to be laid down again.
  systemd.services.wireguard-wg0 = {
    after = [ "netns@${namespace}.service" ];
    bindsTo = [ "netns@${namespace}.service" ];
    partOf = [ "netns@${namespace}.service" ];
  };

  systemd.services."wireguard-wg0-peer-${peerName}" = {
    after = [ "netns@${namespace}.service" ];
    bindsTo = [ "netns@${namespace}.service" ];
    partOf = [ "netns@${namespace}.service" ];
  };

  # --------------------------------------------------------------------------
  # DNS.
  #
  # `ip netns exec` bind-mounts /etc/netns/<ns>/resolv.conf automatically;
  # systemd's NetworkNamespacePath= does not, so it is bound explicitly below.
  # --------------------------------------------------------------------------
  environment.etc."netns/${namespace}/resolv.conf".text = ''
    nameserver ${vpnDns}
    options edns0
  '';

  # --------------------------------------------------------------------------
  # Transmission.
  # --------------------------------------------------------------------------
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;

    # Shares the group jellyfin.nix created, so Jellyfin can read completed
    # downloads without a copy step.
    group = "media";

    credentialsFile = config.sops.secrets.transmission-credentials.path;

    # Left null so transmission-setup.service does not fight the tmpfiles rules
    # below over ownership and mode. Nothing else pulls that unit in, and the
    # settings directory it would otherwise create is already covered by the
    # module's StateDirectory=.
    downloadDirPermissions = null;

    settings = {
      download-dir = "${mediaDir}/downloads";
      incomplete-dir = "${mediaDir}/incomplete";
      incomplete-dir-enabled = true;

      # Group-writable output, so files land readable by the media group. The
      # setgid bit on the tmpfiles directories keeps the group on new files.
      umask = 2;

      # Listens only on loopback *inside* the namespace. The only way in is
      # the socket proxy below.
      rpc-bind-address = "127.0.0.1";
      rpc-port = rpcPort;
      rpc-authentication-required = true;

      # Every request arrives from the proxy as 127.0.0.1, so this no longer
      # filters by real source address -- the tailscale0-only firewall rule is
      # what does that. Kept enabled to reject anything that reaches the
      # loopback listener by another path.
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.1";

      # Inert while a password is set (transmission returns early from
      # isHostnameAllowed when auth is on) and it would only break access by
      # hostname, since every request's Host header arrives via the proxy.
      rpc-host-whitelist-enabled = false;

      # 2 = require encrypted peer connections (0 off, 1 prefer). Obfuscation
      # against DPI throttling only; it does nothing for address privacy, which
      # is the tunnel's job.
      encryption = 2;

      # Local peer discovery has nothing to discover inside the namespace.
      lpd-enabled = false;

      # The port-forward unit below drives the peer port via NAT-PMP, so it
      # must not be randomised out from under it, and Transmission's own
      # port mapping must stay out of the way: Proton only answers the
      # "public port 1, local port 0" form that natpmpc sends.
      peer-port = 51413;
      peer-port-random-on-start = false;
      port-forwarding-enabled = false;
    };
  };

  systemd.services.transmission = {
    # wireguard-wg0.target rather than wireguard-wg0.service: the service alone
    # leaves the namespace with an up interface and an empty routing table,
    # because the default route comes from the peer unit. The target is ordered
    # after both.
    wants = [ "wireguard-wg0.target" ];
    after = [
      "netns@${namespace}.service"
      "wireguard-wg0.target"
    ];
    # Not bindsTo wireguard-wg0: if the tunnel drops, Transmission should stay
    # up and fail closed against an empty routing table rather than restart.
    bindsTo = [ "netns@${namespace}.service" ];
    partOf = [ "netns@${namespace}.service" ];

    serviceConfig = {
      NetworkNamespacePath = "/run/netns/${namespace}";

      # The upstream module already sets BindReadOnlyPaths, and unit options
      # merge by concatenation, so mkAfter appends rather than replaces. The
      # nesting under /etc takes care of itself: systemd sorts mount entries by
      # path, so this one is applied after /etc regardless of list order.
      BindReadOnlyPaths = lib.mkAfter [
        "/etc/netns/${namespace}/resolv.conf:/etc/resolv.conf"
      ];

      # nsncd runs in the init namespace and would resolve names there --
      # a DNS leak straight past the tunnel. Cutting off its socket forces
      # glibc to resolve in-process against the resolv.conf bound above.
      InaccessiblePaths = [ "-/run/nscd" ];
    };
  };

  # --------------------------------------------------------------------------
  # Port forwarding.
  #
  # Without an open port Transmission can only make outbound connections, which
  # works but badly limits peer discovery. Proton exposes NAT-PMP on the tunnel
  # gateway, but only honours the "map public port 1, local port 0" request,
  # which is not the form Transmission's built-in port mapping sends -- hence
  # natpmpc here and port-forwarding-enabled = false above.
  #
  # Proton assigns the port rather than taking a request, and it can change on
  # every renewal, so the assigned port is pushed into Transmission whenever it
  # differs from the one already set.
  # --------------------------------------------------------------------------
  systemd.services.transmission-port-forward = {
    description = "Proton NAT-PMP port forwarding for Transmission";
    wantedBy = [ "multi-user.target" ];
    after = [
      "netns@${namespace}.service"
      "wireguard-wg0.target"
      "transmission.service"
    ];
    wants = [ "wireguard-wg0.target" ];
    bindsTo = [ "netns@${namespace}.service" ];
    # transmission.service as well as the namespace: the module rewrites
    # settings.json from the store on every start, putting peer-port back to
    # the literal above. The loop only pushes a port when it differs from the
    # one it last set, and Proton usually re-grants the same port, so without
    # restarting alongside Transmission the mapping is silently dropped.
    partOf = [
      "netns@${namespace}.service"
      "transmission.service"
    ];

    path = [
      pkgs.libnatpmp
      pkgs.jq
      config.services.transmission.package
    ];

    # Any failure here -- tunnel down, gateway not answering, Transmission not
    # up yet -- exits and is retried, rather than being papered over and
    # leaving a stale mapping in place.
    script = ''
      TR_AUTH="$(jq -r '[."rpc-username" // "", ."rpc-password" // ""] | join(":")' \
        "$CREDENTIALS_DIRECTORY/rpc")"
      export TR_AUTH

      mapped=""
      while :; do
        response="$(natpmpc -g ${vpnGateway} -a 1 0 udp ${toString portLifetime})"
        natpmpc -g ${vpnGateway} -a 1 0 tcp ${toString portLifetime} >/dev/null

        port="$(printf '%s\n' "$response" \
          | sed -n 's/^Mapped public port \([0-9][0-9]*\).*/\1/p' | head -n1)"
        if [ -z "$port" ]; then
          echo "natpmpc returned no mapped port" >&2
          exit 1
        fi

        if [ "$port" != "$mapped" ]; then
          echo "Proton assigned peer port $port"
          transmission-remote 127.0.0.1:${toString rpcPort} --authenv --port "$port" >/dev/null
          mapped="$port"
        fi

        sleep ${toString portRenewInterval}
      done
    '';

    serviceConfig = {
      NetworkNamespacePath = "/run/netns/${namespace}";
      Restart = "always";
      RestartSec = 10;

      # --authenv reads TR_AUTH from the environment, so the password never
      # reaches a command line. The credential itself is root-only, which
      # LoadCredential= resolves before the DynamicUser= identity exists.
      LoadCredential = "rpc:${config.sops.secrets.transmission-credentials.path}";

      DynamicUser = true;
      CapabilityBoundingSet = "";
      AmbientCapabilities = "";
      NoNewPrivileges = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" ];
    };
  };

  # --------------------------------------------------------------------------
  # RPC access.
  #
  # systemd opens the listening socket in the init namespace and hands the fd
  # to a proxy running inside `vpn`, which forwards to Transmission's
  # loopback listener. No veth, no bridge, no route out of the namespace --
  # the only thing crossing the boundary is an already-accepted file
  # descriptor, which cannot carry traffic outward.
  # --------------------------------------------------------------------------
  systemd.sockets.transmission-rpc-proxy = {
    description = "Transmission RPC proxy socket";
    wantedBy = [ "sockets.target" ];
    socketConfig.ListenStream = toString rpcPort;
  };

  systemd.services.transmission-rpc-proxy = {
    description = "Transmission RPC proxy into the ${namespace} namespace";
    requires = [ "transmission-rpc-proxy.socket" ];
    after = [
      "transmission-rpc-proxy.socket"
      "netns@${namespace}.service"
      "transmission.service"
    ];
    bindsTo = [ "netns@${namespace}.service" ];
    partOf = [ "netns@${namespace}.service" ];

    serviceConfig = {
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString rpcPort}";
      NetworkNamespacePath = "/run/netns/${namespace}";

      DynamicUser = true;
      CapabilityBoundingSet = "";
      AmbientCapabilities = "";
      NoNewPrivileges = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" ];
    };
  };

  # Same exposure pattern as jellyfin.nix: reachable over the tailnet only.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ rpcPort ];

  systemd.tmpfiles.rules = [
    "d ${mediaDir}/downloads 2775 ethan media -"
    "d ${mediaDir}/incomplete 2775 ethan media -"
  ];

  assertions = [
    {
      assertion = !lib.hasInfix placeholder protonPublicKey;
      message = "transmission.nix: set protonPublicKey to the [Peer] PublicKey from your Proton WireGuard config.";
    }
    {
      assertion = !lib.hasInfix placeholder protonEndpoint;
      message = "transmission.nix: set protonEndpoint to the [Peer] Endpoint from your Proton WireGuard config.";
    }
  ];
}
