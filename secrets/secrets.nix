let
  willi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTU+w/41oNnBH7Zf9qa5PIREYSzlAwRkdvYpym5BF4j";

  think = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDseXq0mgC/CN9CtgZeduV7MG1h0wzohUS+Cy+hzRMBz";
in {
  "password.age".publicKeys = [willi think];
  "root-password.age".publicKeys = [willi think];
}
