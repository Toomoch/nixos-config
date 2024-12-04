{ pkgs, ... }:
let
  filemanager = "thunar";
  browser = "firefox";
in {
  wayland.windowManager.river = {
    enable = true;
    package = null;
    extraConfig = builtins.readFile ./dotfiles/riverinit.sh;
    extraSessionVariables = {
    };
  };
  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "river";
    XDG_SESSION_DESKTOP = "river";
  };

}
