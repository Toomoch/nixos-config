{ inputs, pkgs, lib, config, ... }:
let

  #huawei-solar = pkgs.callPackage ../../packages/huawei-solar.nix {
  #  python3 = pkgs.python312;

  #};
  #huawei_solar = pkgs.callPackage ../../packages/huawei_solar.nix {
  #  inherit huawei-solar;
  #};
  cfg = config.custom.homeassistant;
in {

  options.custom.homeassistant.enable =
    lib.mkEnableOption "Whether to enable homelab stuff";

  config = lib.mkIf cfg.enable {
  };
}
