{ config, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../personal.nix
  ];

  home.stateVersion = "23.05";
}
