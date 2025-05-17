{ pkgs, lib, config, ... }:
{
  options.custom.dev = {
    enable = lib.mkEnableOption "Devtools";
  };
  config.home.packages =
    with pkgs;
    lib.optionals config.custom.dev.enable [
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
      (python3.withPackages (ps: [
        ps.pip
        ps.requests
        ps.python-gitlab
        ps.pygments
      ]))
      nixd
      file
      git-agecrypt
    ];
}
