{
  config,
  pkgs,
  lib,
  ...
}:
let
  DP_ultrawide = "LG Electronics LG ULTRAWIDE 0x0003BECD";
in
{

  custom = {
    wl = {
      enable = true;
      river.enable = true;
    };
    desktop.enable = true;
  };

  home.stateVersion = "22.11";
}
