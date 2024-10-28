let
  # this key is used so we do not need root access when rekeying
  willi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTU+w/41oNnBH7Zf9qa5PIREYSzlAwRkdvYpym5BF4j";

  think = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDseXq0mgC/CN9CtgZeduV7MG1h0wzohUS+Cy+hzRMBz";
  main = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDdftcbfr7MVnbjMPzRL1KHfOoYkwnDScyZCJWcSBmN";

  cloud = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtWXfbInoez4N3XF8ec7ZMAl8PUzojSvJxB9tBi+rW7";

  desktops = [main think];
  servers = [cloud];
  users = [willi];
in {
  "root-password.age".publicKeys = desktops ++ servers ++ users;

  "password.age".publicKeys = desktops ++ users;
  "willi-id_ed25519.age".publicKeys = desktops ++ users;
  "mumble-cert.age".publicKeys = desktops ++ users;

  "initrd-ssh-host-key.age".publicKeys = servers ++ users;
}
