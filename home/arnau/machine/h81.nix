{ config, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../homelab.nix
  ];

  home.stateVersion = "23.05";
}
