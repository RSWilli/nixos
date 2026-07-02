{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel
  # boot.kernelPackages = pkgs.linuxPackages_zen; # zen kernel, patched for everyday desktop performance

  # GTT (shared-RAM) cap the iGPU (Radeon 860M) may borrow so the Vulkan backend can
  # map large models instead of the 512 MiB VRAM carveout. A cap, not a reservation.
  boot.kernelParams = let
    gtt = 24; # GiB of max shared VRAM
    gttPages = gtt * 1024 * 1024 * 1024 / 4096;
  in [
    "ttm.pages_limit=${toString gttPages}"
    "ttm.page_pool_size=${toString gttPages}"
  ];

  # OOM backstop on top of zram: the high GTT cap leaves little RAM headroom, so a
  # true disk overflow prevents the OOM killer from taking llama-server (or the
  # session) under memory pressure. zram (prio 5) is still used first.
  # GPU-pinned GTT pages are never swappable; this only catches CPU-side spillover.
  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024; # MiB
    }
  ];

  my = {
    ai = {
      enable = true;
      backend = "vulkan"; # gfx1152 iGPU: RADV is faster than ROCm + uses GTT/shared RAM
    };
    docker.enable = true;

    desktop = {
      gnome.enable = true;
      enableAutoLogin = true;

      amd = true;

      communication = {
        matrix = true;
      };
    };

    users = {
      willi.enable = true;
    };

    work = {
      enable = true;
    };
  };

  # fingerprint sensor, see https://wiki.nixos.org/wiki/Fingerprint_scanner
  # run `fprintd-enroll` to enroll a fingerprint
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-broadcom-cv3plus; # for dell keyboard fingerprint sensor
    };
  };

  # Laptop battery optimizations https://nixos.wiki/wiki/Laptop
  powerManagement.enable = true;

  # powertop and auto tune service
  powerManagement.powertop.enable = true;

  # BIOS updates, run `fwupdmgr update` to check for updates and install them
  # https://wiki.nixos.org/wiki/Fwupd
  services.fwupd.enable = true;

  networking.hostName = "dell";
}
