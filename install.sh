#!/bin/sh

# helper to start the install nix shell without any configuration needed
nix-shell -A "devShells.x86_64-linux.install"
