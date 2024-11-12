{ pkgs, pkgs-unstable, nixpkgs-unstable, ... }:
{
  home.packages = with pkgs; [
    graphviz
    kubectl
    openfortivpn
    texliveFull
    zathura
    minizinc
    or-tools
  ];

}
