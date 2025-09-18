{
  python3,
  fetchPypi,
}: let
  # globre is removed from nixpkgs, so fetch it locally
  globre = python3.pkgs.buildPythonPackage rec {
    pname = "globre";
    version = "0.1.5";
    format = "setuptools";

    src = fetchPypi {
      inherit pname version;

      sha256 = "1qhjpg0722871dm5m7mmldf6c7mx58fbdvk1ix5i3s9py82448gf";
    };
  };
in
  # ported from https://archlinux.org/packages/extra/any/python-gitlabber/
  python3.pkgs.buildPythonApplication rec {
    pname = "gitlabber";
    version = "1.2.8";
    format = "setuptools";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-euqxDM6jwZzod2N42oqSIAaWKT8sROMEAbVIIdeeb5Y=";
    };

    propagatedBuildInputs = with python3.pkgs; [
      setuptools
      # https://github.com/ezbz/gitlabber/blob/master/requirements.txt
      anytree
      gitpython
      python-gitlab
      globre
      pyyaml
      tqdm
      docopt
    ];
  }
