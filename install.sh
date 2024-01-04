#!/bin/sh

#
# install the system given with the argument
#

# format disks:
sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/disko -- --flake "$(pwd)#$1" --mode disko

# generate configuration:
nixos-generate-config --no-filesystems --show-hardware-config >"./systems/$1/hardware-configuration.nix"

# install system:
sudo nixos-install --flake ".#$1"
