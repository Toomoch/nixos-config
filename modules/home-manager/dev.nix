{
  pkgs,
  lib,
  config,
  ...
}:
let
  sopsPlugins = pkgs.sops.withAgePlugins (p: [ p.age-plugin-fido2-hmac ]);
in
{
  options.custom.dev = {
    enable = lib.mkEnableOption "Devtools";
  };
  config.home.packages =
    with pkgs;
    lib.optionals config.custom.dev.enable [
      #dev tools
      libclang
      #nixfmt-classic
      nixfmt-rfc-style
      shellcheck
      shfmt
      gnumake
      rage
      age-plugin-fido2-hmac
      sopsPlugins
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
