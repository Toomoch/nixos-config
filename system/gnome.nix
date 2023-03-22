{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    
  ];

  # Enable Gnome
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;




}
