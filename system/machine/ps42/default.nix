{ config, pkgs, lib, ... }:
{
  networking.hostName = "ps42-nix"; # Define your hostname.

  environment.systemPackages = with pkgs; [
    powertop    
  ];

  # Enable vaapi hardware acceleration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
    ];
  };

  # Power management and undervolt
  services.tlp = {
    enable = true;
    settings = {
      SOUND_POWER_SAVE_ON_AC = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;
      RUNTIME_PM_ON_AC = "auto";
      PCIE_ASPM_ON_AC = "powersave";
      PCIE_ASPM_ON_BAT = "powersave";
    };
  };
  services.undervolt = {
    enable = true;
    coreOffset = -70;
    uncoreOffset = -20;
    gpuOffset = -30;
    analogioOffset = -20;
  };

  # Disable nvidia gpu
  boot.blacklistedKernelModules = [ "nouveau" ];
  # Remove NVIDIA VGA/3D controller devices
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
}
