#!/usr/bin/env just --justfile

gitadd:
  git add . && cd private && git add . && cd -

default:
  @just --list

deploy HOSTNAME: gitadd
  deploy .\?submodules=1#{{HOSTNAME}} --skip-checks

deployremote HOSTNAME: gitadd
  deploy .\?submodules=1#{{HOSTNAME}} --skip-checks --remote-build

build HOSTNAME="$(hostname)": gitadd
  nixos-rebuild build --flake .\?submodules=1#{{HOSTNAME}}

rebuild HOSTNAME="$(hostname)": gitadd
  sudo nixos-rebuild switch --flake .\?submodules=1#{{HOSTNAME}}

droid: gitadd
  nix-on-droid switch --flake .\?submodules=1

update:
  nix flake update

cleangen:
  sudo nix-collect-garbage -d && nix-collect-garbage -d

