{ config, lib, pkgs, ... }:

{
  # Read the changelog before changing this value
  home.stateVersion = "23.11";
  imports = [ ../default.nix ];
  # insert home-manager config
}
