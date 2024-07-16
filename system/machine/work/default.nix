{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    "${inputs.private}/system/machine/work.nix"
    ../../users/arnau.nix
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
  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };

  services.fprintd = {
    enable = true;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-goodix-550a;
  };

  virtualisation = {
    docker = {
      #rootless = {
      #  enable = true;
      #  setSocketVariable = true;
      #};
    };
  };

  systemd.tmpfiles.rules = [
    "d /external 0775 arnau users - -"
  ];

  fileSystems."/external" = {
    device = "/dev/disk/by-uuid/4f3d6384-e04d-4ece-9470-891d31a4f316";
    options = [ "nofail" "compress=zstd" ];
  };
  networking.firewall.allowedTCPPorts = [
    5900
    8000
  ];
  system.stateVersion = "23.05";
}

