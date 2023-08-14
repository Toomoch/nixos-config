{ inputs, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../desktop.nix
    ../sway
    #../hyprland
  ];

  home.stateVersion = "22.11";
}
