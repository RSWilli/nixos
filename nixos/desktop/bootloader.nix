{ lib, config, ... }:
with lib;
let
  cfg = config.my.desktop;
in
{
  config = mkIf cfg.enable {
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  };
}