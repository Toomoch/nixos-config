{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    headsetcontrol
  ];

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

  # Arctis 9
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12c2", TAG+="uaccess"
  '';

  # ADB
  programs.adb.enable = true;

  # Firefox
  programs.firefox = {
    enable = true;
    preferences = {
      "browser.fullscreen.autohide" = false;
    };
  };




}
