#!/usr/bin/env -S just --justfile

gitadd:
  git add . && cd private && git add . && cd -

default:
  @just --list

deploy HOSTNAME: gitadd
  deploy .#{{HOSTNAME}} --skip-checks

deployremote HOSTNAME: gitadd
  deploy .#{{HOSTNAME}} --skip-checks --remote-build


build HOSTNAME="$(hostname)": gitadd
  nixos-rebuild build --flake .#{{HOSTNAME}} --show-trace

rebuildremote HOSTNAME="$(hostname)": gitadd
  ssh-add && \
  user=$(ssh -G h81 | grep -w ^user | cut -d " " -f2) && \
  host=$(ssh -G h81 | grep -w ^hostname | cut -d " " -f2) && \
  sudo NIX_SSHOPTS="-o ForwardAgent=yes" nixos-rebuild switch --flake .#{{HOSTNAME}} --build-host ${user}@${host}

rebuild HOSTNAME="$(hostname)": gitadd
  sudo nixos-rebuild switch --flake .#{{HOSTNAME}}

test HOSTNAME="$(hostname)": gitadd
  sudo nixos-rebuild test --flake .#{{HOSTNAME}}

boot HOSTNAME="$(hostname)": gitadd
  sudo nixos-rebuild boot --flake .#{{HOSTNAME}}

rebuildtarget HOSTNAME: gitadd
  nixos-rebuild switch --flake .#{{HOSTNAME}} --target-host {{HOSTNAME}} --sudo

rebuildtargetremote HOSTNAME: gitadd
  nixos-rebuild switch --flake .#{{HOSTNAME}} --target-host {{HOSTNAME}} --sudo --build-host {{HOSTNAME}}


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
