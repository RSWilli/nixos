{pkgs, ...}: {
  imports = [];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "de";
    xkbVariant = "";

    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "willi";
  };

  services.printing.enable = true; # cups

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  environment.systemPackages = [
    pkgs.pavucontrol
    pkgs.easyeffects
  ];

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gnome-connections
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-maps
      #gnome-terminal
      #gedit # text editor
      epiphany # web browser
      geary # email reader
      evince # document viewer
      #gnome-characters
      #totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # Help view
      gnome-contacts
      gnome-initial-setup
    ]);

  programs.dconf.enable = true;
}
