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
    python3
    kubectl
    nixd
    file
    texliveFull
    python311Packages.pygments
    zathura
  ];
}
