{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../desktop.nix
    ../sway
    ../personal.nix
    ../devtools.nix
    ../nvim.nix
  ];

  home.packages = with pkgs; [
    discord-screenaudio
  ];

  home.stateVersion = "22.11";
}
