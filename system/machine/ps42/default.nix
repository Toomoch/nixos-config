{ config, pkgs, lib, ... }:
{
  networking.hostName = "ps42-nix"; # Define your hostname.
  # undervolt...
  services.power-profiles-daemon.enable = true;
  services.undervolt = {
    enable = true;
    coreOffset = -70;
    unCore = -20;
    gpuOffset = -30;
    analogioOffset = -20;
  };
}
