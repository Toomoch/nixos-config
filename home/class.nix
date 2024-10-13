{ pkgs, ... }:
{
  home.packages = with pkgs; [
    graphviz
    kubectl
    openfortivpn
    unityhub
    texliveFull
    zathura
  ];

}
