{ config, lib, pkgs, ... }:
with lib; let
  cfg = config.desktop;
in
{
  options.desktop = {
    enable = mkEnableOption ("Whether to enable common stuff for desktop systems");
    arctis9.enable = mkEnableOption ("Whether to enable Arctis9 support");
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Arctis 9
      #environment.systemPackages = with pkgs; [
      #] ++ optional cfg.arctis9.enable "headsetcontrol";
      #
      #services.udev.extraRules = optionalString cfg.arctis9.enable ''
      #  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12c2", TAG+="uaccess"'';

      # Printing
      services.printing.enable = true;
      services.avahi.enable = true;
      # for a WiFi printer
      services.avahi.openFirewall = true;

      # OpenGL    
      hardware.opengl.enable = true;
      hardware.opengl.driSupport = true;
      hardware.opengl.driSupport32Bit = true;

      # PipeWire
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
      hardware.pulseaudio.enable = false;

      # Bluetooth
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = false;

      # ADB
      programs.adb.enable = true;

      # Firefox
      programs.firefox = {
        enable = true;
        preferences = {
          "browser.fullscreen.autohide" = false;
        };
      };
    })
    (mkIf cfg.arctis9.enable {
      # Arctis 9
      services.udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12c2", TAG+="uaccess"
      '';
      environment.systemPackages = with pkgs; [
        headsetcontrol
      ];

    })


  ];
}
