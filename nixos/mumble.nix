{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    (pkgs.mumble.override {pipewireSupport = true;})
  ];

  # add mumble cert to home directory
  age.secrets."mumble-cert.p12" = {
    file = ../secrets/mumble-cert.age;
    path = "/home/willi/mumble-cert.p12";
    owner = "willi";
    mode = "600";
  };
}
