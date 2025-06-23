{ inputs, config, pkgs, lib, secrets, private, ... }:
let
  homeDir = "${config.users.users.${user}.home}";
  user = "${secrets.hosts.${config.networking.hostName}.user}";
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = secrets.work.hostName;
  custom.common.enable = true;
  custom.common.systemd-boot.enable = true;
  custom.desktop.enable = true;
  custom.desktop.regreet.enable = true;
  custom.desktop.sway.enable = true;
  custom.desktop.river.enable = true;
  custom.desktop.niri.enable = true;
  custom.vm.podman.enable = true;
  custom.vm.docker.enable = true;
  custom.vm.libvirtd.enable = true;

  programs.singularity = {
    enable = true;
    package = pkgs.apptainer;
    enableSuid = true;
    enableFakeroot = true;
  };
  programs.winbox = {
    enable = true;
    openFirewall = true;
    package = pkgs.unstable.winbox4;
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
  programs.ssh.knownHosts.${secrets.work.sshFs}.publicKey = secrets.work.knownHost;

  fileSystems."/workspace" = { # infinite recursion if homeDir is used???
    device = "${user}@${secrets.work.sshFs}:";
    fsType = "sshfs";
    options = [
      "nodev"
      "noatime"
      "allow_other"
      "nofail"
      "ServerAliveInterval=5"
      "reconnect"
      "IdentityFile=${homeDir}/.ssh/id_ed25519"
    ];
  };


  home-manager.users.${user} =
    { pkgs, ... }:
    {
      imports = [ ./home-manager.nix ];
    };

  system.stateVersion = "24.05";
}

