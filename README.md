# nixos-config
# Table of Contents
- [Installation](#installation)
   * [Installing NixOS in UEFI x86 manually](#installing-nixos-in-uefi-x86-manually)
   * [Installing NixOS with nixos-anywhere](#installing-nixos-with-nixos-anywhere)
   * [Building a NixOS sdimage for the Raspberry Pi](#building-a-nixos-sdimage-for-the-raspberry-pi)
   * [Home Manager for **Non-NixOS** systems](#home-manager-for-non-nixos-systems)
- [Deployment](#deployment)
   * [Deploying NixOS locally](#deploying-nixos-locally)
   * [Deploying NixOS over the network with deploy-rs](#deploying-nixos-over-the-network-with-deploy-rs)

## Installation
### Installing NixOS in UEFI x86 manually
Follow [the official manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual)

### Installing NixOS with nixos-anywhere
To check that the configuration is bootable, run:
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#hostname --vm-test
```

Boot the installer and change the root password, then run:
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#hostname root@ip
```

### Building a NixOS sdimage for the Raspberry Pi
```bash
nix build .#nixosConfigurations.rpi3.config.system.build.sdImage
```
This image can later be flashed with dd.

### Home Manager for **Non-NixOS** systems

Install nix:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Add to ~/.config/nix/nix.conf:

```
experimental-features = nix-command flakes
```

And then run:

```bash
nix run home-manager/master -- init --switch
mkdir ~/projects && cd ~/projects
git clone https://github.com/Toomoch/nixos-config.git && cd nixos-config
home-manager switch --flake .#username
```

## Deployment
### Deploying NixOS locally
For our hostname:
```bash
just rebuild
```
For a specific hostname:
```bash
just rebuild hostname
```

### Deploying NixOS over the network with deploy-rs
To build the configuration locally, and then copy it to the target (useful for systems with limited resources, such as a pi):
```bash
just deploy hostname
```
To build the configuration directly on the target machine:
```bash
just deployremote hostname
```
