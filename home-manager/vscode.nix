# https://nixos.wiki/wiki/Visual_Studio_Code
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.vscode = {
    enable = true;
  };
}
