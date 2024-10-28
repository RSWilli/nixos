#!/usr/bin/env bash

#
# this script uses nixos-anywhere to install a remote system
# before the installation it creates new ssh_host_keys, prints the public key
# and waits for the user to rekey the secrets before passing them to the
# installation
#
# usage:
#   ./install_remote_system.sh <hostname> <user@host> [extra nixos-anywhere arguments]
#

set -euo pipefail

# Check if the hostname and remote host are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <hostname> <user@host>"
    exit 1
fi

# ask the user if the tranfer directory should be removed, if it exists
if [ -d "transfer" ]; then
    read -r -p "The transfer directory already exists, do you want to remove it? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        rm -rf "transfer"
    else
        echo "re-using the existing transfer directory"
    fi
fi

# Create the transfer directory
mkdir -p transfer

# create the ssh host keys if not present in the transfer directory
if [ ! -f "transfer/etc/ssh/ssh_host_ed25519_key" ]; then
    install -d -m755 "transfer/etc/ssh"
    ssh-keygen -A -f "transfer"
fi

# Print the public key
cat "transfer/etc/ssh/ssh_host_ed25519_key.pub"

# Wait for the user to rekey the secrets
echo please rekey use the public key above to rekey the secrets
read -r -p "Press enter to continue installation"

# Install NixOS to the host system with our secrets
# we need to pass all args separately
# shellcheck disable=SC2068
nix run github:nix-community/nixos-anywhere -- --extra-files "transfer" --flake ".#$1" ${@:3} "$2"
