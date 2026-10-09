# declaritive wifi configuration. Does not disallow adding additional networks via the GUI.
# set my.wifi.cleanup.enable to remove all wifi networks not declared by this module once a week
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.wifi;

  # stable uuid generator
  mkUuid = label: let
    h = builtins.hashString "sha256" "wifi-profile:${label}";
    s = n: len: builtins.substring n len h;
  in "${s 0 8}-${s 8 4}-4${s 12 3}-a${s 15 3}-${s 18 12}";

  # "standard" wifi with password. label gets mapped to WIFI_<LABEL>_SSID and WIFI_<LABEL>_PSK in the secret env file
  mkWifi = label: overrides: let
    L = lib.toUpper label;
  in
    lib.recursiveUpdate {
      connection = {
        id = label;
        uuid = mkUuid label;
        type = "wifi";
        autoconnect = true;
      };
      wifi = {
        mode = "infrastructure";
        ssid = "$WIFI_${L}_SSID";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_${L}_PSK";
      };
      ipv4.method = "auto";
      ipv6 = {
        method = "auto";
        addr-gen-mode = "stable-privacy";
      };
    }
    overrides;

  # open wifi config, no password
  mkOpen = ssid: overrides:
    lib.recursiveUpdate {
      connection = {
        id = ssid;
        uuid = mkUuid ssid;
        type = "wifi";
        autoconnect = true;
      };
      wifi = {
        mode = "infrastructure";
        ssid = ssid;
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    }
    overrides;

  # keys in the secret file, with overrides for the network config
  pskNetworks = {
    home = {connection.autoconnect-priority = 100;};
    home24 = {connection.autoconnect-priority = 10;};
    work = {};
    willihotspot = {connection.autoconnect-priority = -10;};
    kase = {};
  };

  # public SSIDs, with overrides
  openNetworks = {
    # only works with docker when docker is not on 172.18.x.x
    "WIFIonICE" = {connection.autoconnect-priority = -100;}; # lower than hotspot, because of https://www.youtube.com/watch?v=uellmynA34U
    # Czech train wifi:
    "CDWiFi" = {connection.autoconnect-priority = -100;};
  };
in {
  options.my.wifi = {
    enable = mkEnableOption "wifi";
    cleanup.enable = mkEnableOption "weekly removal of wifi networks not declared by this module";
  };

  config = mkIf cfg.enable {
    age.secrets.wifi-ssids.file = ../secrets/wifi-ssids.age;

    networking.networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [config.age.secrets.wifi-ssids.path];
        profiles =
          lib.mapAttrs mkWifi pskNetworks
          // lib.mapAttrs mkOpen openNetworks;
      };
    };

    # declared profiles live in /run/NetworkManager, GUI-added ones in /etc/NetworkManager
    systemd.services.wifi-cleanup = mkIf cfg.cleanup.enable {
      description = "Remove wifi networks not declared in the nixos config";
      after = ["NetworkManager.service"];
      requires = ["NetworkManager.service"];
      path = [config.networking.networkmanager.package pkgs.gawk pkgs.findutils];
      serviceConfig.Type = "oneshot";
      script = ''
        nmcli -t -f UUID,TYPE,FILENAME connection show \
          | awk -F: '$2 == "802-11-wireless" && $3 ~ "^/etc/NetworkManager" {print $1}' \
          | xargs -rn1 nmcli connection delete
      '';
    };

    systemd.timers.wifi-cleanup = mkIf cfg.cleanup.enable {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };
  };
}
