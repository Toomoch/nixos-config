{ config, pkgs, lib, ... }:
{
  #List of services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Printing
  services.printing.enable = true;
  services.avahi.enable = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  #OpenGL    
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  #PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  #Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  #Udisks
  services.udisks2.enable = true;

  #gvfs
  services.gvfs.enable = true;
  services.dbus.enable = true;

  #thumbler
  services.tumbler.enable = true;

  #xdg-portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    # Enable libvirt
    libvirtd.enable = true;
  };

  #OpenRGB
  services.hardware.openrgb.enable = true;

  #Gnome Keyring
  services.gnome.gnome-keyring.enable = true;

  #Arctis 9
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12c2", TAG+="uaccess"
  '';

  #Allow all VPN traffic routing
  networking.firewall.checkReversePath = "loose";
}
