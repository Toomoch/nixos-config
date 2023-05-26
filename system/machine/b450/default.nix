{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../users/arnau.nix
    ../../default.nix
    ../../desktop.nix
    ../../gaming.nix
    ../../sway.nix
    ../../virtualisation.nix
  ];

  # Enable vaapi hardware acceleration
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
    };
  };

  networking.hostName = "b450"; # Define your hostname.
  
  #OpenRGB
  services.hardware.openrgb.enable = true;


}
