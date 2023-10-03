{ ... }:
{
  imports = [
    ../default.nix
    ../work.nix
  ];

  home.username = "arnau";
  home.homeDirectory = "/home/arnau";
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;

}
