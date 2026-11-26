{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop;
in {
  options.my.desktop = {
    libreoffice = mkEnableOption "LibreOffice with spell checking and MS Office compatible fonts";
  };

  config = mkIf cfg.libreoffice {
    # see https://wiki.nixos.org/wiki/LibreOffice
    environment.systemPackages = with pkgs; [
      libreoffice-qt # Qt variant integrates with KDE

      # spell checking
      hunspell
      hunspellDicts.de_DE
      hunspellDicts.en_US
    ];

    fonts.packages = with pkgs; [
      corefonts # Arial, Times New Roman, ...
      vista-fonts # Calibri, Cambria, ...
      noto-fonts
      noto-fonts-color-emoji
    ];
  };
}
