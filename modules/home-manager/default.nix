{ lib, ... }:
{
  imports = [
    ./waylandWindowManagers
    ./arnau.nix
    ./desktop.nix
    ./dev.nix
  ];

}
