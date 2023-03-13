{ config, pkgs, lib, ... }:
{
  #List of programs that you want to enable:


  #Thunar
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];

  #Sway
  programs.sway.enable = true;
  programs.sway.wrapperFeatures.gtk = true;
  programs.dconf.enable = true;

  #Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  #ADB
  programs.adb.enable = true;
}
