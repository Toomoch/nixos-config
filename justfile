#!/usr/bin/env just --justfile

default:
  @just --list

deploy HOSTNAME:
  git add . && nix run github:serokell/deploy-rs .#{{HOSTNAME}}

rebuild HOSTNAME="$(hostname)":
  git add . && nix flake archive && sudo 'NIX_SSHOPTS=-i $HOME/.ssh/id_ed25519' nixos-rebuild switch --flake .#{{HOSTNAME}}