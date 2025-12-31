{
  config,
  pkgs,
  lib,
  private,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  custom.desktop.enable = true;
  custom.desktop.wm = {
    enable = true;
    greeter = "regreet";
    sway.enable = true;
    hyprland.enable = false;
    niri.enable = true;
  };
  custom.dev.enable = true;

  custom.vm.podman.enable = true;
  custom.vm.docker.enable = true;
  custom.vm.libvirtd.enable = true;

  programs.winbox = {
    enable = true;
    openFirewall = true;
  };

  services.auto-cpufreq.enable = true;

  # Enable VAAPI hardware acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
    };
  };

  zramSwap.enable = true;

  #nfs mount
  environment.systemPackages = with pkgs; [
    nfs-utils
    vscode.fhs
    openssl
  ];

  users.users.arnau.home = "/home/avalls";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  home-manager.users.arnau =
    { pkgs, ... }:
    {
      imports = [ ./home-manager.nix ];
    };

  system.stateVersion = "24.05";
}
