{ config, pkgs, lib, ... }:
{
  networking.hostName = "ps42"; # Define your hostname.

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
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
    };
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

  # Don’t shutdown when power button is short-pressed
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
