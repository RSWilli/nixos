{
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];
  age.secrets = {
    password.file = ./password.age;
    root-password.file = ./root-password.age;
  };
}
