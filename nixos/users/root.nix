{
  lib,
  config,
  ...
}: {
  users.users = {
    root = {
      hashedPasswordFile = config.age.secrets.root-password.path;
      openssh.authorizedKeys.keys = [
        lib.my.publicKey
      ];
    };
  };
}
