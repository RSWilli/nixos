# Wrapper package for noctalia-shell, containing all settings and configuration. Also see niri.nix.
#
# https://birdeehub.github.io/nix-wrapper-modules/wrapperModules/noctalia-shell.html
{
  pkgs,
  noctaliaShellWrapper,
}:
noctaliaShellWrapper {
  inherit pkgs;

  # allow editing the config through the UI, must be an out-of-store path
  # tmp so it doesn't persist across reboots
  outOfStoreConfig = "/tmp/noctalia-shell";
}
