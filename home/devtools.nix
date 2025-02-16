{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    #dev tools
    llvmPackages_15.libclang
    #nixfmt-classic
    nixfmt-rfc-style
    shellcheck
    shfmt
    gnumake
    sops
    rage
    age-plugin-fido2-hmac
    ansible_2_16
    ansible-lint
    uv
    sshpass
    just
    tio
    tldr
    (python3.withPackages(ps: [ ps.pip ps.requests ps.python-gitlab ps.pygments ]))
    nixd
    file
    git-agecrypt
  ];
}
