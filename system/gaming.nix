{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    legendary-gl
    wineWowPackages.stable
    dxvk
    heroic
    bottles
    gamescope
    oversteer
    obs-studio
    webcord
    protonup-qt
  ];


  #Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  #G29 wheel
  hardware.new-lg4ff.enable = true;
  services.udev.packages = with pkgs; [ oversteer ];



}
