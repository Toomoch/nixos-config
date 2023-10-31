{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../desktop.nix
    ../sway
    ../personal.nix
    ../devtools.nix
    #../hyprland
  ];  

  home.stateVersion = "22.11";
}
