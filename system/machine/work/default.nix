{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    "${inputs.private}/system/user.nix"
    ./disko.nix
  ];

  common.enable = true;
  common.x86.enable = true;
  desktop.enable = true;
  desktop.regreet.enable = true;
  desktop.sway.enable = true;
  vm.podman.enable = true;
  vm.docker.enable = true;
  vm.libvirtd.enable = true;

  services.auto-cpufreq.enable = true;

  # Enable VAAPI hardware acceleration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
    };
  };

  #nfs mount
  environment.systemPackages = with pkgs; [
    nfs-utils
    vscode.fhs
    openssl
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };


  system.stateVersion = "24.05";
}

