#!/usr/bin/env just --justfile

default:
  @just --list

deploy HOSTNAME:
  git add . && deploy .\?submodules=1#{{HOSTNAME}} --skip-checks

deployremote HOSTNAME:
  git add . && deploy .\?submodules=1#{{HOSTNAME}} --skip-checks --remote-build

build HOSTNAME="$(hostname)":
  git add . && nixos-rebuild build --flake .\?submodules=1#{{HOSTNAME}}

rebuild HOSTNAME="$(hostname)":
  git add . && sudo nixos-rebuild switch --flake .\?submodules=1#{{HOSTNAME}}

droid:
  git add . && nix-on-droid switch --flake .

update:
  nix flake update

updateprivate:
  nix flake lock --update-input private
