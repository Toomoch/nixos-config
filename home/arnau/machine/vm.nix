{ config, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../desktop.nix
  ];

  home.stateVersion = "23.05";
}
