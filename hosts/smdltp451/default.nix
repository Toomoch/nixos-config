{
  config,
  pkgs,
  lib,
  private,
  self,
  ...
}:
let
  inherit (self.inputs) wrappers;
in
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

  users.users.arnau.home = "/home/avalls";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  users.users.arnau.packages = with pkgs; [
    glab
    freerdp
    cmake
    pandoc
    bind
    tigervnc
    vscode.fhs
  ];

  services.kanshi.package =
    let

      internal_name = "Samsung Display Corp. 0x417B Unknown";
      workplace_name = "ASUSTek COMPUTER INC VG34VQEL1A S4LMDW002954";
    in
    (
      (import ../../modules/wrappers/kanshi.nix {
        inherit lib;
        wlib = wrappers.lib;
      }).apply
      {
        inherit pkgs;
        configFile.content = ''
          profile laptop {
            output "${internal_name}" enable scale 2.000000
          }

          profile workspace {
            output "${workplace_name}" enable mode 3440x1440@75Hz position 1440,0 scale 1.25
            output "${internal_name}" enable position 0,540 scale 2.0
            exec ${lib.getExe config.programs.niri.package} msg action move-workspace-to-monitor --reference "" "${internal_name}"
            exec ${lib.getExe config.programs.niri.package} msg action move-workspace-to-monitor --reference "" "${workplace_name}"
            exec ${lib.getExe config.programs.niri.package} msg action move-workspace-to-monitor --reference "" "${workplace_name}"
          }

        '';
      }
    ).wrapper;

  system.stateVersion = "24.05";
}
