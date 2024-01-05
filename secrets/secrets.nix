let
  # this key is used so we do not need root access when rekeying
  willi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTU+w/41oNnBH7Zf9qa5PIREYSzlAwRkdvYpym5BF4j";

  think = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDseXq0mgC/CN9CtgZeduV7MG1h0wzohUS+Cy+hzRMBz";
  main = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDdftcbfr7MVnbjMPzRL1KHfOoYkwnDScyZCJWcSBmN";

  systems = [main think];
  users = [willi];
  all = systems ++ users;
in {
  "password.age".publicKeys = all;
  "root-password.age".publicKeys = all;
  "willi-id_ed25519.age".publicKeys = all;
}
