{ config, pkgs, lib, ... }:
{
  networking.hostName = "ps42-nix"; # Define your hostname.

  imports = [
    ../../desktop.nix
    ../../sway.nix
    ../../virtualisation.nix
  ];

  # undervolt...
  services.power-profiles-daemon.enable = true;
  services.undervolt = {
    enable = true;
    coreOffset = -70;
    uncoreOffset = -20;
    gpuOffset = -30;
    analogioOffset = -20;
  };
}
