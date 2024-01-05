{ inputs, config, pkgs, lib, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ../../users/arnau.nix
    ../../users/aina.nix
  ];

  config = lib.mkMerge [
    ({
      networking.hostName = "ps42"; # Define your hostname.

      specialisation = {
        kde = {
          configuration = {
            desktop.blacklistnvidia.enable = true;
            desktop.kde.enable = true;
            desktop.flatpak.enable = true;
            environment.systemPackages = with pkgs; [
              libsForQt5.kpat
              libsForQt5.kio-gdrive
            ];

            i18n.defaultLocale = lib.mkDefault "ca_ES.UTF-8";
          };
        };
        nvidia = {
          configuration = {
            desktop.sway.enable = true;
            environment.systemPackages = [
              nvidia-offload
            ];
            desktop.hyprland.enable = false;
            # Power management
            services.auto-cpufreq.enable = true;
            services.tlp = {
              enable = false;
              settings = {
                SOUND_POWER_SAVE_ON_AC = 1;
                SOUND_POWER_SAVE_ON_BAT = 1;
                RUNTIME_PM_ON_AC = "auto";
                PCIE_ASPM_ON_AC = "powersave";
                PCIE_ASPM_ON_BAT = "powersupersave";
              };
            };
            services.xserver.videoDrivers = [ "nvidia" ];
            environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/card0";
            # Nvidia driver bruh moment https://github.com/NVIDIA/egl-wayland/issues/72 TODO revert on nvidia 550
            hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs (old: {
              postPatch = ''
                substituteInPlace ./kernel/nvidia-drm/nvidia-drm-drv.c --replace \
                  '#if defined(NV_SYNC_FILE_GET_FENCE_PRESENT)' \
                  '#if 0'
              '';
            });
            hardware.nvidia = {

              # Modesetting is required.
              modesetting.enable = true;
              powerManagement.enable = true;
              nvidiaSettings = true;
              prime = {
                intelBusId = "PCI:0:2:0";
                nvidiaBusId = "PCI:3:0:0";
                offload = {
                  enable = true;
                  enableOffloadCmd = true;
                };
              };
            };
          };
        };
      };

      environment.systemPackages = with pkgs; [
        powertop
        cemu
      ];

      common.enable = true;
      common.x86.enable = true;
      desktop.enable = true;
      desktop.arctis9.enable = false;
      desktop.matlab.enable = true;
      vm.podman.enable = true;
      vm.libvirtd.enable = false;


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

      # LTS Kernel
      boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "22.11"; # Did you read the comment?
    })
    (lib.mkIf (config.specialisation != { }) {
      desktop.blacklistnvidia.enable = true;
      desktop.sway.enable = true;
      desktop.hyprland.enable = false;
      # Power management
      services.auto-cpufreq.enable = true;
      services.tlp = {
        enable = false;
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
