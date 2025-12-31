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

    ];
  config.programs.uv = lib.optionalAttrs config.custom.dev.enable {
    enable = true;
    settings = {
      python-downloads = "never";
      python-preference = "only-system";
    };
  };
}
