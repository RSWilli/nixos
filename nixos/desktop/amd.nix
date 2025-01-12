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
      # this causes black boxes https://gitlab.gnome.org/GNOME/gtk/-/issues/6890 , re-enable when fixed
      # pkgs.amdvlk

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

    environment.sessionVariables = {
      # Radeon RX 7800XT needs for ROCm 11.0.0 as per: https://llvm.org/docs/AMDGPUUsage.html
      # defined by the gfx1100
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    };
  };
}
