#!/usr/bin/env bash

#
# this script uses nixos-anywhere to install a remote system
# before the installation it creates new ssh_host_keys, prints the public key
# and waits for the user to rekey the secrets before passing them to the
# installation
#
# usage:
#   ./install_remote_system.sh <hostname> <user@host>
#

set -euo pipefail

# Check if the hostname and remote host are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <hostname> <user@host>"
    exit 1
fi

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
    rm -rf "$temp"
}
trap cleanup EXIT

install -d -m755 "$temp/etc/ssh"

ssh-keygen -A -f "$temp"

# Print the public key
cat "$temp/etc/ssh/ssh_host_ed25519_key.pub"

# Wait for the user to rekey the secrets
echo please rekey use the public key above to rekey the secrets
read -r -p "Press enter to continue installation"

# Install NixOS to the host system with our secrets
nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake ".#$1" "$2"
