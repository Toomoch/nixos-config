{ config, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    #../homelab.nix
    ../personal.nix
  ];

  home.stateVersion = "23.05";
}
