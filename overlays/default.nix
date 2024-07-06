{inputs, ...}: {
  # make the custom packages available
  additions = final: _prev: import ../packages final.pkgs;

  # override rnnoise because v0.2 is broken
  working-rnnoise = final: prev: let
    working-rnnoise =
      import inputs.nixpkgs-rnnoise
      {
        system = prev.stdenv.hostPlatform.system;
        config = prev.config;
      };
  in {
    easyeffects = prev.easyeffects.override {rnnoise = working-rnnoise.rnnoise;};
  };
}
