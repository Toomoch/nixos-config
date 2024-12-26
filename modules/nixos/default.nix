{ config, lib, ... }:
let
in {
  imports = [
    ./desktop.nix
    ./de.nix
    ./virtualisation.nix
    ./common.nix
    ./homelab
    ./secrets.nix
    ./vfio.nix
    ./waylandWindowManagers.nix
  ];
  custom.common.enable = lib.mkDefault true;
  custom.secrets.enable = lib.mkDefault true;
}
