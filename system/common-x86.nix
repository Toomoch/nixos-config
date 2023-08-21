{ config, pkgs, lib, nixpkgs, ... }:
{
  imports = [
    ./common-noarch.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 20;

}
