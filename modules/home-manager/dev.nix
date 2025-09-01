{
  pkgs,
  lib,
  config,
  ...
}:
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
      # ansible_2_16
      # ansible-lint
      uv
      sshpass
      just
      tio
      tldr
      python313
      nixd
      file
      git-agecrypt
    ];
  config.programs.uv = lib.optionalAttrs config.custom.dev.enable {
    enable = true;
    settings = {
      python-downloads = "never";
      python-preference = "only-system";
    };
  };
}
