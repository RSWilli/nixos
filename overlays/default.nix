{...}: {
  # make the custom packages available
  custompackages = final: _prev: import ../packages final.pkgs;
}
