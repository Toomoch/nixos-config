{ config, pkgs, lib, ... }:
{
  networking.hostName = "b450-nix"; # Define your hostname.

  #G29 wheel
  hardware.new-lg4ff.enable = true;
  services.udev.packages = with pkgs; [ oversteer ];
}
