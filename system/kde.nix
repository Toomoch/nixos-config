{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [

  ];

  # Enable KDE Plasma
  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  programs.dconf.enable = true;



}
