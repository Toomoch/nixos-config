{ config, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../arnau.nix
    ../personal.nix
  ];

  home.stateVersion = "23.05";
}
