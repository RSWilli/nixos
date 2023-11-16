{
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_rsa_key"
  ];
  age.secrets = {
    password.file = ./password.age;
    root-password.file = ./root-password.age;
  };
}
