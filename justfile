#!/usr/bin/env just --justfile

default:
  @just --list

deploy HOSTNAME:
  nix run github:serokell/deploy-rs .#{{HOSTNAME}} -- --skip-checks

rebuild HOSTNAME="$(hostname)":
  git add . && sudo 'NIX_SSHOPTS=-i /home/arnau/.ssh/id_ed25519' nixos-rebuild switch --flake .#{{HOSTNAME}}