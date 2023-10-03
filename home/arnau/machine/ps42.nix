{ inputs, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../desktop.nix
    ../sway
    ../personal.nix
    #../hyprland
  ];

  home.stateVersion = "22.11";
}
