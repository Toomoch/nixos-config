{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  DP_ultrawide = "LG Electronics LG ULTRAWIDE 0x0003BECD";
  inherit (self.inputs) wrappers;
in
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
  custom.dev.enable = true;
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

  # set kanshi config
  services.kanshi.package =
    (
      (import ../../modules/wrappers/kanshi.nix {
        inherit lib;
        wlib = wrappers.lib;
      }).apply
      {
        inherit pkgs;
        configFile.content = ''
          profile desk_flat {
            output "${DP_ultrawide}" enable mode 2560x1080@99.943Hz position 0,0 adaptive_sync off
          }
        '';
      }
    ).wrapper;

  users.users.arnau.packages = [ pkgs.discord ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
