{
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_rsa_key"
    "/run/media/willi/installer-keys/install_key" # while installing
    "/run/media/nixos/installer-keys/install_key" # only on live ISO
  ];
  age.secrets = {
    password.file = ./password.age;
    root-password.file = ./root-password.age;
  };
}
