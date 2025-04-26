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
  nixos-rebuild build --flake .\?submodules=1#{{HOSTNAME}} --show-trace

rebuildremote HOSTNAME="$(hostname)": gitadd
  ssh-add && \
  user=$(ssh -G h81 | grep -w ^user | cut -d " " -f2) && \
  host=$(ssh -G h81 | grep -w ^hostname | cut -d " " -f2) && \
  sudo NIX_SSHOPTS="-o ForwardAgent=yes" nixos-rebuild switch --flake .\?submodules=1#{{HOSTNAME}} --build-host ${user}@${host}

rebuild HOSTNAME="$(hostname)": gitadd
  sudo nixos-rebuild switch --flake .\?submodules=1#{{HOSTNAME}}

boot HOSTNAME="$(hostname)": gitadd
  sudo nixos-rebuild boot --flake .\?submodules=1#{{HOSTNAME}}

rebuildtarget HOSTNAME: gitadd
  nixos-rebuild switch --flake .\?submodules=1#{{HOSTNAME}} --target-host {{HOSTNAME}} --use-remote-sudo

rebuildtargetremote HOSTNAME: gitadd
  nixos-rebuild switch --flake .\?submodules=1#{{HOSTNAME}} --target-host {{HOSTNAME}} --use-remote-sudo --build-host {{HOSTNAME}}


droid: gitadd
  nix-on-droid switch --flake .\?submodules=1

update:
  nix flake update

cleangen:
  sudo nix-collect-garbage -d && nix-collect-garbage -d

repl:
  nix repl --expr 'builtins.getFlake (toString ./.)'

revision:
  nixos-version --configuration-revision

show:
  git show $(nixos-version --configuration-revision)
