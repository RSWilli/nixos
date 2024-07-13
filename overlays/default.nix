{inputs, ...}: {
  # make the custom packages available
  additions = final: _prev: import ../packages final.pkgs;

  # override rnnoise because v0.2 is broken
  working-rnnoise = final: prev: {
    easyeffects = prev.easyeffects.override {
      rnnoise = inputs.nixpkgs-rnnoise.legacyPackages.${prev.system}.rnnoise;
    };
  };
}
