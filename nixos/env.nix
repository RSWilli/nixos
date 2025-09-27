# global environment variables that I want to set everywhere and that do not have anything in common
# with other parts of the system setup
{
  lib,
  config,
  pkgs,
  ...
}: {
  environment.variables = {
    # https://go.dev/doc/toolchain#GOTOOLCHAIN
    # otherwise go tries to switch the toolchain by downloading the one mentioned in the go.mod
    GOTOOLCHAIN = "local";
  };
}
