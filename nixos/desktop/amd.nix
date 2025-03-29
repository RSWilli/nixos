{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop;
in {
  options.my.desktop.amd = mkEnableOption "amd";

  config = mkIf cfg.amd {
    hardware.graphics.extraPackages = [
      pkgs.amdvlk

      # ROCm
      pkgs.rocmPackages.clr.icd
    ];

    nixpkgs.config.rocmSupport = true;

    boot.kernelModules = ["kvm-amd"];
    boot.initrd.kernelModules = ["amdgpu"];

    environment.systemPackages = with pkgs; [
      radeontop
      clinfo
    ];

    # fix ROCm path for software where it is hardcoded
    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
  };
}
