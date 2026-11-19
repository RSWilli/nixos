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

  my = {
    server = {
      enable = true;

      domain = "w-bartel.de";

      paperless.enable = true;
      vaultwarden.enable = true;
      immich.enable = true;
      teamspeak.enable = true;
    };

    autoUpgrade = {
      enable = true;
      autoReboot = true;
    };

    luksAutoUnlock.enable = true;

    backup.enable = true;
    backup.directory = "/backup";

    wifi.enable = true;
    wifi.cleanup.enable = true;
  };

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "homelab";

  # The BIOS enables PCIe ASPM (L0s/L1 + L1 substates) on the link to the QCA9377 wifi card (ath10k).
  # That causes a constant stream of PCIe AER errors and after ~30 min the card stops answering
  # ("ath10k_pci: failed to wake target"), taking the network down until a power cycle.
  # The FADT declares ASPM unsupported, so the kernel keeps the BIOS setting and pcie_aspm=off
  # does nothing; clear the ASPM control bits of both link ends directly instead.
  systemd.services.disable-wifi-aspm = {
    description = "Disable PCIe ASPM on the wifi card link";
    wantedBy = ["multi-user.target"];
    before = ["NetworkManager.service"];
    serviceConfig.Type = "oneshot";
    script = ''
      # downstream (wifi card) first, then the root port
      ${pkgs.pciutils}/bin/setpci -s 02:00.0 CAP_EXP+0x10.w=0x0000:0x0003
      ${pkgs.pciutils}/bin/setpci -s 00:1c.7 CAP_EXP+0x10.w=0x0000:0x0003
    '';
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.11";
}
