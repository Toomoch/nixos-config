{ config, pkgs, lib, ... }:
{
  networking.hostName = "b450-nix"; # Define your hostname.
  
  #OpenRGB
  services.hardware.openrgb.enable = true;


}
