{pkgs, lib, ...}:
{
  home.packages = with pkgs; [
    #dev tools
    llvmPackages_15.libclang
    nixpkgs-fmt
    nixfmt
    nixd
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
    python3
    texliveFull
    
  ];
}