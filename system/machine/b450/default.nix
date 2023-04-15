{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../default.nix
    ../../desktop.nix
    ../../gaming.nix
    ../../sway.nix
    ../../virtualisation.nix
  ];


  networking.hostName = "b450"; # Define your hostname.
  
  #OpenRGB
  services.hardware.openrgb.enable = true;


}
