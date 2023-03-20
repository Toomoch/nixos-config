{ config, pkgs, lib, ... }:
{
  networking.hostName = "vm-nix"; # Define your hostname.
  
  imports = [
    ../../desktop.nix
    ../../sway.nix
  ];
}
