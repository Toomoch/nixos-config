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
      waybar.enable = true;
      niri.enable = true;
    };
    desktop.enable = true;
    dev.enable = true;
  };

  home.packages = with pkgs; [ discord ];
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile = {
          name = "desk_flat";
          outputs = [
            {
              criteria = DP_ultrawide;
              position = "0,0";
              mode = "2560x1080@99.943Hz";
              adaptiveSync = false;
              status = "enable";
            }
          ];
        };
      }
    ];
  };

  home.stateVersion = "22.11";
}
