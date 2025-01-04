{
  fetchFromGitHub,
  buildDotnetModule,
  lib,
  git,
  musl,
  xorg,
  libxcrypt-legacy,
  dotnetCorePackages,
}:
buildDotnetModule rec {
  pname = "StabilityMatrix";
  version = "2.12.4";

  src = fetchFromGitHub {
    owner = "LykosAI";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-GYp1Wg7jbF6FGi+MLemLXKx3otAH8E0zQriMp9fFUAI=";
    leaveDotGit = true; # the build needs the git dir for whatever reason
  };

  projectFile = "StabilityMatrix.Avalonia/StabilityMatrix.Avalonia.csproj";

  dotnet-sdk = with dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_9_0
    ];
  dotnet-runtime = with dotnetCorePackages;
    combinePackages [
      runtime_8_0
      runtime_9_0
    ];

  nativeBuildInputs = [
    git
  ];

  buildInputs = [
    musl
  ];

  nugetDeps = ./deps.json;
  runtimeDeps = [
    musl
    libxcrypt-legacy
    # icu

    # Avalonia UI
    xorg.libX11
    xorg.libICE
    xorg.libSM
    xorg.libXi
    xorg.libXcursor
    xorg.libXext
    xorg.libXrandr
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
  ];

  meta = with lib; {
    homepage = "https://github.com/LykosAI/StabilityMatrix";
    description = "Multi-Platform Package Manager for Stable Diffusion";
    license = licenses.gpl3;
  };
}
