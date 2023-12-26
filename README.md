# nixos-config

## Installing with home-manager **Non-NixOS**:

Install nix:

`sh <(curl -L https://nixos.org/nix/install) --daemon`

Add to ~/.config/nix/nix.conf:

`experimental-features = nix-command flakes`

And then run:

`nix run home-manager/master -- init --switch`

`mkdir ~/projects && cd ~/projects`

`git clone https://github.com/Toomoch/nixos-config.git && cd nixos-config`

`home-manager switch --flake .#username`

## Installing NixOS in UEFI x86
Follow [the official manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual)

## Building a NixOS sdimage for the Raspberry Pi
```bash
nix build .#nixosConfigurations.rpi3.config.system.build.sdImage
```

## Deploying NixOS with deploy-rs
```bash
nix run github:serokell/deploy-rs .#hostname -- --skip-checks
```

