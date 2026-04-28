# https://wiki.nixos.org/wiki/AMD_GPU
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
      # ROCm
      pkgs.rocmPackages.clr.icd
    ];

    nixpkgs.config.rocmSupport = true;
    hardware.amdgpu.opencl.enable = true;

    hardware.amdgpu.initrd.enable = true;

    environment.systemPackages = with pkgs; [
      radeontop
      clinfo
    ];

    # fix ROCm path for software where it is hardcoded
    systemd.tmpfiles.rules = let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas

          # amd common language runtime
          clr
        ];
      };
    in [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];

    # linux AMD GPU controller
    # services.lact.enable = true;
  };
}
