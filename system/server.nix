{ config, pkgs, lib, ... }:
{
  services.cockpit.enable = true;
  services.cockpit.openFirewall = true;
}
