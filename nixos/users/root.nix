{
  lib,
  config,
  ...
}: {
  age.secrets.root-password.file = ../../secrets/root-password.age;

  users.users = {
    root = {
      hashedPasswordFile = config.age.secrets.root-password.path;
      openssh.authorizedKeys.keys = [
        lib.my.publicKey
      ];
    };
  };
}
