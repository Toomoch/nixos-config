{
  config,
  pkgs,
  lib,
  sops-nix,
  inputs,
  ...
}:
{
  networking.hostName = "b450"; # Define your hostname.

  imports = [ ./hardware-configuration.nix ];

  # Enable VAAPI hardware acceleration
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };
  programs.steam.gamescopeSession.args = [
    "--adaptive-sync"
    "-R 100"
  ];

  custom.common.enable = true;

  custom.vm.podman.enable = true;
  custom.vm.libvirtd.enable = true;
  custom.vm.docker.enable = true;
  virtualisation.waydroid.enable = true;

  custom.desktop = {
    enable = true;
    wm = {
      enable = true;
      greeter = "regreet";
      sway.enable = true;
      hyprland.enable = false;
      niri.enable = true;
    };
    flatpak.enable = true;
    gaming = {
      enable = true;
      g29.enable = true;
    };
    arctis9.enable = true;
  };

  # programs.singularity = {
  #   enable = true;
  #   package = pkgs.apptainer;
  #   enableSuid = true;
  #   enableFakeroot = true;
  # };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # OpenRGB
  services.hardware.openrgb.enable = true;

  # Enable the IOMMU
  boot.kernelParams = [ "amd_iommu=on" ];
  boot.loader.systemd-boot.windows = {
    "10".efiDeviceHandle = "HD1b65535a1";
  };

  custom.common.wol.enable = true;
  # LTS Kernel
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  home-manager.users.arnau =
    { pkgs, ... }:
    {
      imports = [ ./home-manager.nix ];
    };
}
