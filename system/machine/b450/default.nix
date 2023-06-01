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

  # Don’t shutdown when power button is short-pressed
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
