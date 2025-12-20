{
  inputs,
  config,
  pkgs,
  lib,
  osConfig,
  private,
  ...
}:
let
  internal_name = "Samsung Display Corp. 0x417B Unknown";
  workplace_name = "ASUSTek COMPUTER INC VG34VQEL1A S4LMDW002954";
  ultrawide_hdmi_name = "LG Electronics LG ULTRAWIDE 0x0003BECD";
  hostname = osConfig.networking.hostName;

in
{

  home.packages = with pkgs; [
    glab
    freerdp
    cmake
    pandoc
    bind
    tigervnc
  ];

  home.homeDirectory = lib.mkForce "/home/avalls";

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

  programs.git.lfs.enable = true;

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = internal_name;
            status = "enable";
            scale = 2.0;
          }
        ];
      }
      {
        profile.name = "workspace";
        profile.exec = [
          ''niri msg action move-workspace-to-monitor --reference "" "${internal_name}"''
          ''niri msg action move-workspace-to-monitor --reference "" "${workplace_name}"''
          ''niri msg action move-workspace-to-monitor --reference "" "${workplace_name}"''
        ];
        profile.outputs = [
          {
            criteria = workplace_name;
            mode = "3440x1440@75Hz";
            position = "1440,0";
            scale = 1.25;
            status = "enable";
          }
          {
            criteria = internal_name;
            position = "0,540";
            scale = 2.0;
            status = "enable";
          }
        ];
      }
    ];
  };

  home.stateVersion = "24.11";
}
