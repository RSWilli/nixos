# My NixOS configuration

This repo contains the flake configuration for my NixOS systems. Will always be a work in progress.

Currently the following systems are configured:

- `think`: My laptop, a Lenovo Thinkpad X13

Apply the configuration with 

```bash
nixos-rebuild switch --flake .#$hostname
```
