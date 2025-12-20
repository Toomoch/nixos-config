{
  config,
  pkgs,
  lib,
  ...
}:
{

  custom = {
    desktop.enable = true;
    dev.enable = true;
  };

  home.stateVersion = "23.05";
}
