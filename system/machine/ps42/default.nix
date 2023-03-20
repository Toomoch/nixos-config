{ config, pkgs, lib, ... }:
{
  networking.hostName = "ps42-nix"; # Define your hostname.

  imports = [
    ../../desktop.nix
    ../../sway.nix
    ../../virtualisation.nix
  ];

  # vaapi
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
    ];
  };

  # undervolt...
  services.power-profiles-daemon.enable = true;
  services.undervolt = {
    enable = true;
    coreOffset = -70;
    uncoreOffset = -20;
    gpuOffset = -30;
    analogioOffset = -20;
  };

  #disable nvidia gpu
  boot.blacklistedKernelModules = [ "nouveau" ];
  # Remove NVIDIA VGA/3D controller devices
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
}
