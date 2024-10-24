{ pkgs, pkgs-unstable, nixpkgs-unstable, ... }:
{
  home.packages = with pkgs; [
    graphviz
    kubectl
    openfortivpn
    pkgs-unstable.unityhub
    texliveFull
    zathura
    minizinc
    or-tools
  ];

}
