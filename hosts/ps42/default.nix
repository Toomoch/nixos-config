{ inputs, config, pkgs, lib, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {
  imports =
    [ ./hardware-configuration.nix  ];

  config = lib.mkMerge [
    {
      networking.hostName = "ps42"; # Define your hostname.

      specialisation = {
        kde = {
          configuration = {
            custom.desktop.blacklistnvidia.enable = true;
            custom.desktop.kde.enable = true;
            custom.desktop.flatpak.enable = true;
            environment.systemPackages = with pkgs; [
              libsForQt5.kpat
              libsForQt5.kio-gdrive
            ];
            i18n.defaultLocale = lib.mkDefault "ca_ES.UTF-8";
          };
        };
        # disabled
        # nvidia = {
        #   configuration = {
        #     desktop.regreet.enable = true;
        #     desktop.sway.enable = true;
        #     environment.systemPackages = [ nvidia-offload ];
        #     desktop.hyprland.enable = false;
        #     # Power management
        #     services.tlp = {
        #       enable = true;
        #       settings = {
        #         SOUND_POWER_SAVE_ON_AC = 1;
        #         SOUND_POWER_SAVE_ON_BAT = 1;
        #         RUNTIME_PM_ON_AC = "auto";
        #         PCIE_ASPM_ON_AC = "powersave";
        #         PCIE_ASPM_ON_BAT = "powersupersave";
        #       };
        #     };
        #     services.xserver.videoDrivers = [ "nvidia" ];
        #     environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/card1";
        #     hardware.nvidia.package =
        #       config.boot.kernelPackages.nvidiaPackages.stable;
        #     hardware.nvidia = {
        #       # Modesetting is required.
        #       modesetting.enable = true;
        #       powerManagement.enable = true;
        #       nvidiaSettings = true;
        #       prime = {
        #         intelBusId = "PCI:0:2:0";
        #         nvidiaBusId = "PCI:3:0:0";
        #         offload = {
        #           enable = true;
        #          enableOffloadCmd = true;
        #        };
        #      };
        #    };
        #  };
        #};
      };

      environment.systemPackages = with pkgs; [ powertop prismlauncher ];

      custom.common.enable = true;
      custom.common.systemd-boot.enable = true;
      custom.desktop.enable = true;
      custom.desktop.arctis9.enable = false;
      custom.desktop.matlab.enable = false;
      custom.vm.podman.enable = true;
      #vm.libvirtd.enable = false;

      # Enable VAAPI hardware acceleration
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [ intel-media-driver ];
      };
      programs.firefox = {
        enable = true;
        preferences = { "media.ffmpeg.vaapi.enabled" = true; };
      };

      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

      # Undervolt
      services.undervolt = {
        enable = true;
        coreOffset = -77;
        uncoreOffset = -20;
        gpuOffset = -30;
        analogioOffset = -20;
      };

      # Enable the IOMMU
      boot.kernelParams = [ "intel_iommu=on" ];

      virtualisation.waydroid.enable = false;

      # LTS Kernel
      #boot.kernelPackages = pkgs.linuxPackages_latest;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "22.11"; # Did you read the comment?
    }
    (lib.mkIf (config.specialisation != { }) {
      custom.desktop.blacklistnvidia.enable = true;
      custom.desktop.sway.enable = true;
      custom.desktop.tuigreet.enable = true;
      custom.desktop.regreet.enable = false;
      custom.desktop.river.enable = true;
      custom.desktop.hyprland.enable = false;
      custom.vm.libvirtd.enable = true;
      custom.vfio = {
        enable = true;
        devices = [ "10de:1d10" ];
      };
      services.tlp = {
        enable = true;
        settings = {
          SOUND_POWER_SAVE_ON_AC = 1;
          SOUND_POWER_SAVE_ON_BAT = 1;
          RUNTIME_PM_ON_AC = "auto";
          PCIE_ASPM_ON_AC = "powersave";
          PCIE_ASPM_ON_BAT = "powersupersave";
        };
      };
    })
  ];

}
