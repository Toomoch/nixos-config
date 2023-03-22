{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    headsetcontrol
    scrcpy
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

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  
  # ADB
  programs.adb.enable = true;
  users.users.arnau.extraGroups = [ "adbusers" ];

  # Arctis 9
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12c2", TAG+="uaccess"
  '';

  # Firefox
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "browser.fullscreen.autohide" = false;
    };
  };

  # Enable wayland in electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  

}
