inputs: {
  # make the custom packages available under "custompackages", package import requires a package instance and flake inputs
  custompackages = final: _prev: {
    custompackages = import ../packages (
      {
        pkgs = final.pkgs;
      }
      // inputs
    );
  };
}
