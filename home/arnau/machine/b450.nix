{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../desktop.nix
    ../sway
    inputs.sops-nix.homeManagerModules.sops
  ];

  #sops = {
  #  age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  #  secrets.dashy = {
  #    format = "binary";
  #    sopsFile = ../dashy.yaml;
  #    path = "%r/test.txt"; 
  #  };
  #};

  home.stateVersion = "22.11";
}
