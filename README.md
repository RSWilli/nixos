# My NixOS configuration

## Description

This repo contains the flake configuration for my NixOS systems. Will always be a work in progress.

Currently the following systems are configured:

- `think`: My laptop, a Lenovo Thinkpad X13

Apply the configuration with 

```bash
nixos-rebuild switch --flake .#$hostname
```

## Creating a new system

1. Add the public key of the new system to `secrets/secrets.nix`.
   * use `agenix` to rekey the secrets on a machine with an already configured key
2. Add a new folder in `systems/` with the hostname of the new system. In the `systems/<name>/default.nix` configure the system. Also add the entry to `flake.nix` in the `nixosConfigurations` list.
3. run `nix-shell` in the root of this repo to configure the flakes and download dependencies
4. TODO: how to start `install` dev shell?
5. run `format <hostname>` to format the system with the config
6. generate the hardware configuration with `hw-config <hostname>` and import the file in the `systems/<hostname>/default.nix` file
7. run `install <hostname>` to install the system