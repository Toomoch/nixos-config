{ inputs, config, pkgs, lib, secrets, private, ... }:
let
  homeDir = "${config.users.users.${user}.home}";
  user = "${secrets.hosts.${config.networking.hostName}.user}";
in
{
  imports = [
    ./hardware-configuration.nix
    "${private}/system/user.nix"
    ./disko.nix
  ];

  networking.hostName = secrets.work.hostName;
  common.enable = true;
  common.x86.enable = true;
  desktop.enable = true;
  desktop.regreet.enable = true;
  desktop.sway.enable = true;
  vm.podman.enable = true;
  vm.docker.enable = true;
  vm.libvirtd.enable = true;

  programs.singularity = {
    enable = true;
    package = pkgs.apptainer;
    enableSuid = true;
    enableFakeroot = true;
  };
  programs.winbox = {
    enable = true;
    openFirewall = true;
  };

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



  system.stateVersion = "24.05";
}

