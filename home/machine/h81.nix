{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    #../homelab.nix
    ../personal.nix
    ../devtools.nix
    ../nvim.nix
    ../class.nix
    inputs.nixvim.homeManagerModules.nixvim
  ];

  home.stateVersion = "23.05";
}
