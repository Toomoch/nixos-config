{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [

  ];

  # Enable KDE Plasma
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  programs.dconf.enable = true;



}
