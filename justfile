#!/usr/bin/env -S just --justfile
commonRemoteOpts := "--use-substitutes --sudo"

gitadd:
  git add . && cd private && git add . && cd -

default:
  @just --list

deploy HOSTNAME: gitadd
  deploy .#{{HOSTNAME}} --skip-checks

deployremote HOSTNAME: gitadd
  deploy .#{{HOSTNAME}} --skip-checks --remote-build


build HOSTNAME="": gitadd
  nixos-rebuild build --flake .#{{HOSTNAME}} --show-trace

buildremote HOSTNAME="": gitadd
  nixos-rebuild build --flake .#{{HOSTNAME}} --show-trace --build-host h81 {{commonRemoteOpts}}

rebuildremote HOSTNAME="": gitadd
  nixos-rebuild switch --flake .#{{HOSTNAME}} --build-host h81 {{commonRemoteOpts}}

rebuild HOSTNAME="": gitadd
  nixos-rebuild switch --flake .#{{HOSTNAME}} --sudo

test HOSTNAME="": gitadd
  nixos-rebuild test --flake .#{{HOSTNAME}} --sudo

boot HOSTNAME="": gitadd
  nixos-rebuild boot --flake .#{{HOSTNAME}} --sudo

# commonRemoteOpts := "--use-substitutes --sudo"

rebuildtarget HOSTNAME: gitadd
  nixos-rebuild switch --flake .#{{HOSTNAME}} --target-host {{HOSTNAME}} {{commonRemoteOpts}}

rebuildtargetremote HOSTNAME: gitadd
  nixos-rebuild switch --flake .#{{HOSTNAME}} --target-host {{HOSTNAME}} --build-host {{HOSTNAME}} {{commonRemoteOpts}}


droid: gitadd
  nix-on-droid switch --flake .

update:
  nix flake update

cleangen:
  sudo nix-collect-garbage -d && nix-collect-garbage -d

repl:
  nix repl --expr 'builtins.getFlake (toString ./.)'

revision:
  nixos-version --configuration-revision

show HOSTNAME="":
  if [[ -n "{{ HOSTNAME }}" ]]; then HASH="$(ssh {{HOSTNAME}} 'nixos-version --configuration-revision')"; else HASH="$(nixos-version --configuration-revision)"; fi && \
  if git cat-file -e ${HASH} &>/dev/null; then git show ${HASH}; else echo unknown revison \""${HASH}"\"; fi;

size HOSTNAME="$(hostname)":
  nix path-info -Sh  .#nixosConfigurations.{{HOSTNAME}}.config.system.build.toplevel
