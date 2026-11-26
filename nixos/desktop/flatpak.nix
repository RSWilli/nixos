# flatpak with flathub, lets users install apps themselves (e.g. via KDE Discover)
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.desktop;
in {
  options.my.desktop = {
    flatpak = mkEnableOption "flatpak with flathub";
  };

  config = mkIf cfg.flatpak {
    services.flatpak.enable = true;

    # NixOS does not configure a flatpak remote, add flathub
    # https://wiki.nixos.org/wiki/Flatpak
    systemd.services.flatpak-repo = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      path = [config.services.flatpak.package];
      serviceConfig.Type = "oneshot";
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
