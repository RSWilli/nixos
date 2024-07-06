# a minimal mkShell that doesn't include the C compiler
{
  lib,
  stdenvNoCC,
  mkShell,
  ...
}: let
  stdenvMinimal = stdenvNoCC.override {
    cc = null;
    preHook = "";
    allowedRequisites = null;
    initialPath =
      lib.filter
      (a: lib.hasPrefix "coreutils" a.name)
      stdenvNoCC.initialPath;
    extraNativeBuildInputs = [];
  };
in
  mkShell.override {
    stdenv = stdenvMinimal;
  }
