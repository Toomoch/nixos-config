# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let


in
{
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    <home-manager/nixos>
    ./system
  ];

  #home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.users.arnau = { pkgs, ... }: {
    imports = [
      ./home/arnau
    ];
  };

}

