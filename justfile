#!/usr/bin/env just --justfile

default:
  @just --list

deploy HOSTNAME:
  git add . && nix run github:serokell/deploy-rs .#{{HOSTNAME}} -- --skip-checks

deployremote HOSTNAME:
  git add . && nix run github:serokell/deploy-rs .#{{HOSTNAME}} -- --skip-checks --remote-build

build HOSTNAME="$(hostname)":
  git add . && nixos-rebuild build --flake .#{{HOSTNAME}}

rebuild HOSTNAME="$(hostname)":
  git add . && nix flake archive && sudo 'NIX_SSHOPTS=-i $HOME/.ssh/id_ed25519' nixos-rebuild switch --flake .#{{HOSTNAME}}

update:
  nix flake update

updateprivate:
  nix flake lock --update-input private
