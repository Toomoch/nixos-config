{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    #dev tools
    llvmPackages_15.libclang
    nixpkgs-fmt
    nixfmt-classic
    nil
    shellcheck
    shfmt
    erlang
    gnumake
    graphviz
    openfortivpn
    sops
    rage
    age-plugin-fido2-hmac
    ansible
    ansible-lint
    just
    tio
    tldr
    (python3.withPackages(ps: [ ps.ansible ps.pip ps.requests ps.python-gitlab ps.pygments ]))
    kubectl
    nixd
    file
    texliveFull
    zathura
  ];
}
