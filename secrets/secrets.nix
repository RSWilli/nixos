let
  # this key is used so we do not need root access when rekeying
  willi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTU+w/41oNnBH7Zf9qa5PIREYSzlAwRkdvYpym5BF4j";

  think = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDseXq0mgC/CN9CtgZeduV7MG1h0wzohUS+Cy+hzRMBz";
  main = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDdftcbfr7MVnbjMPzRL1KHfOoYkwnDScyZCJWcSBmN";

  homelab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBNQZOU4ou1acFONG02i2fr0k6/qmLCbTUNpfRs95U8q";

  AIRNB0017 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADeWaKQ194hhRQoU6C+Q2xwbaADaDyM9ZYbvxtrvdTS";

  # creative = "TODO";

  all = [willi main homelab think AIRNB0017];
in {
  "root-password.age".publicKeys = all;

  "password.age".publicKeys = all;

  "paperless-admin.age".publicKeys = all;

  "mumble-cert.age".publicKeys = all;

  "wifi-ssids.age".publicKeys = all;

  "willi-id_ed25519.age".publicKeys = all;

  "password-lara.age".publicKeys = all;
}
