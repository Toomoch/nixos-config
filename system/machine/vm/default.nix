{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../default.nix
    ../../desktop.nix
  ];

  networking.hostName = "vm"; # Define your hostname.
  
}
