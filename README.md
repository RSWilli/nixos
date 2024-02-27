# My NixOS configuration

## Description

This repo contains the flake configuration for my NixOS systems. Will always be a work in progress.

Currently the following systems are configured:

- `main`: My desktop gaming PC with an AMD Ryzen 5 5600X and an Nvidia RTX 3080
- `think`: My laptop, a Lenovo Thinkpad X13

## Creating a new system

To create a new system, run the following command:

```bash
install_remote_system.sh <hostname> <user@host>
```

## To output any key set in the flake:

```bash
$ nix repl
nix-repl> :lf .
nix-repl> <key>
```