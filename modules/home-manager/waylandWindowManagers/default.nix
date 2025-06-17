{ lib, ... }:

{
  imports = [
    ./misc.nix
    ./river.nix
    ./sway.nix
    ./waybar.nix
    ./scripts.nix
    ./niri.nix
  ];

}
