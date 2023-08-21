{ config, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../homelab.nix
  ];

  sops = {
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  };

  home.stateVersion = "23.05";
}
