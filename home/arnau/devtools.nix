{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    #dev tools
    llvmPackages_15.libclang
    nixpkgs-fmt
    nixfmt
    nil
    shellcheck
    shfmt
    erlang
    gnumake
    graphviz
    openfortivpn
    sops
    ansible
    ansible-lint
    just
    tio
    tldr
    python3
    kubectl
    nixd
  ];
}
