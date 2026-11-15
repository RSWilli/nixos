# homelab

## Fritz!Box setup

TeamSpeak is reachable from the internet over IPv4 and IPv6, everything else only through the netbird VPN.
The host has a MyFRITZ name (`homelab.<id>.myfritz.net`) that can be used as a CNAME target.

### IPv6 address

The box can only create IPv6 sharings for a device if it knows its IPv6 interface id.
In the `home`/`home24` networks NetworkManager uses mac based (EUI-64) interface ids and no temporary
addresses (see `homeIpv6` in [nixos/wifi.nix](../../nixos/wifi.nix)), so the id is stable and matches the hardware.

The box did not detect the id on its own, it was entered manually in the device settings
(Internet → Freigaben → homelab). Compute it from the mac address, or read it from the host:

```sh
ip -6 addr show scope global   # last 4 blocks, with ff:fe in the middle
```

If the wifi card changes (or the host moves to ethernet), the mac and therefore the interface id change.

### Sharings (Internet → Freigaben → Portfreigaben → homelab)

| Type | Settings | Purpose |
|---|---|---|
| Portfreigabe | UDP 9987, IPv4 and IPv6 | TeamSpeak voice |
| MyFRITZ!-Freigabe | Andere Anwendung, schema `ts3server://`, port 9987 | only to get the MyFRITZ name, see below |

Device settings: only "PING6 freigeben" is enabled. Exposed host (IPv4/IPv6), delegated prefixes and
"Selbstständige Portfreigaben" (UPnP) stay off: the host firewall allows SSH (with password auth),
which must not be reachable from the internet.

The Fritz!Box only creates a `<device>.<id>.myfritz.net` name for devices with a **MyFRITZ!-Freigabe**,
port sharings alone result in NXDOMAIN. The MyFRITZ!-Freigabe forwards TCP 9987, which is dropped by the
host firewall, so nothing is exposed by it. The generated name is shown in the "MyFRITZ!-Adresse" field of the sharing.

"MyFRITZ!-Direktverbindung" is not needed for the DNS names.

### Checking

```sh
dig A    homelab.<id>.myfritz.net @1.1.1.1
dig AAAA homelab.<id>.myfritz.net @1.1.1.1
```
