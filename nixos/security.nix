# system-wide hardening, independent of what runs on the machine
{
  # processes sharing a terminal (sandboxes, su, sudo -u) must not inject
  # keystrokes into the parent shell via TIOCSTI
  boot.kernel.sysctl."dev.tty.legacy_tiocsti" = 0;
}
