{ config, pkgs, lib, ... }:
{
  networking.hostName = "b450-nix"; # Define your hostname.

  imports = [
    ../../desktop.nix
    ../../gaming.nix
    ../../sway.nix
    ../../virtualisation.nix
  ];

  #OpenRGB
  services.hardware.openrgb.enable = true;


}
