{ inputs, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../desktop.nix
    ../sway
  ];

  home.stateVersion = "22.11";
}
