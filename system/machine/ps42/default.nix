{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../users/arnau.nix
    ../../users/aina.nix
    ../../modules
  ];

  config = lib.mkMerge [
    ({
      networking.hostName = "ps42"; # Define your hostname.

      specialisation.kde = {
        configuration = {
          desktop.kde.enable = true;
          environment.systemPackages = with pkgs; [
            netbeans
            libsForQt5.kpat
            libsForQt5.kio-gdrive
          ];

          i18n.defaultLocale = lib.mkDefault "ca_ES.UTF-8";
        };
      };

      environment.systemPackages = with pkgs; [
        powertop
      ];

      common.enable = true;
      common.x86.enable = true;
      desktop.enable = true;
      desktop.arctis9.enable = false;
      desktop.matlab.enable = true;
      vm.podman.enable = true;
      vm.libvirtd.enable = true;

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

      # Undervolt
      services.undervolt = {
        enable = true;
        coreOffset = -70;
        uncoreOffset = -20;
        gpuOffset = -30;
        analogioOffset = -20;
      };

      # Disable NVIDIA module
      boot.blacklistedKernelModules = [ "nouveau" ];
      # Remove NVIDIA VGA/3D controller devices
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
      '';

      # Enable the IOMMU
      boot.kernelParams = [ "intel_iommu=on" ];

      # LTS Kernel
      boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

      #services.code-server.package = inputs.nixpkgs-stable.packages.x86_64-linux.code-server;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "22.11"; # Did you read the comment?
    })
    (lib.mkIf (config.specialisation != { }) {
      desktop.sway.enable = true;
      desktop.hyprland.enable = false;
      # Power management 
      services.tlp = {
        enable = true;
        settings = {
          SOUND_POWER_SAVE_ON_AC = 1;
          SOUND_POWER_SAVE_ON_BAT = 1;
          RUNTIME_PM_ON_AC = "auto";
          PCIE_ASPM_ON_AC = "powersave";
          PCIE_ASPM_ON_BAT = "powersave";
        };
      };
    })
  ];



}
