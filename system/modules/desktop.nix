{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.desktop;
  g29init = pkgs.writeShellScriptBin "g29init" ''
    ${pkgs.coreutils-full}/bin/sleep 8
    ${pkgs.oversteer}/bin/oversteer --range 300
  '';
  matlab-wrapped = pkgs.writeShellScriptBin "matlab" ''
    exec env MESA_GL_VERSION_OVERRIDE=3.0 ${pkgs.matlab}/bin/matlab
  '';
in
{
  options.desktop = {
    enable =
      lib.mkEnableOption "Whether to enable common stuff for desktop systems";
    arctis9.enable = lib.mkEnableOption "Whether to enable Arctis9 support";
    flatpak.enable = lib.mkEnableOption "Whether to enable Flatpak support";
    gaming.enable = lib.mkEnableOption "Whether to enable gaming stuff";
    gaming.g29.enable = lib.mkEnableOption "Whether to enable G29 wheel support";
    matlab.enable = lib.mkEnableOption "Whether to enable MATLAB";
    blacklistnvidia.enable =
      lib.mkEnableOption "Whether to disable and hide all detected Nvidia GPUs";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # Arctis 9
      #environment.systemPackages = with pkgs; [
      #] ++ optional cfg.arctis9.enable "headsetcontrol";
      #
      #services.udev.extraRules = optionalString cfg.arctis9.enable ''
      #  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12c2", TAG+="uaccess"'';

      programs.appimage = {
        enable = true;
        binfmt = true;
      };
      services.fwupd.enable = true;
      fonts = {
        fontconfig.defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
          monospace = [ "Noto Sans Mono" ];
        };

        packages = with pkgs; [
          rubik
          fira-code
          fira-code-symbols
          font-awesome
          noto-fonts
          noto-fonts-extra
          noto-fonts-cjk
          noto-fonts-emoji
        ];
      };
      nixpkgs.config.permittedInsecurePackages = [ "electron-24.8.6" ];

      programs.nix-ld.enable = true;
      services.envfs.enable = true;

      environment.systemPackages = with pkgs; [
        vulkan-tools
        glxinfo
        libva-utils
        localsend
        firefoxpwa
      ];
      networking.firewall.allowedTCPPorts = [
        53317
      ];
      # Printing
      services.printing.enable = true;

      #hardware.printers = {
      #  ensureDefaultPrinter = "brother";
      #  ensurePrinters = [
      #    {
      #      name = "brother";
      #      deviceUri = "ipp://BRWD46A6A756DB9/ipp";
      #      model = "drv:///cupsfilters.drv/pwgrast.ppd ";
      #      description = "Brother DCP-L2530DW Series";
      #      location = "Casa";
      #    }
      #  ];
      #};
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      # Tailscale
      services.tailscale = {
        enable = true;
      };
      systemd.services."tailscaled".wantedBy = lib.mkForce [];

      # OpenGL    
      hardware.opengl.enable = true;
      hardware.opengl.driSupport = true;
      hardware.opengl.driSupport32Bit = true;

      # PipeWire
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
      hardware.pulseaudio.enable = false;

      # Bluetooth
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = false;

      # ADB
      programs.adb.enable = true;

      # Firefox
      programs.firefox =
        let
          firefox-package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
            nativeMessagingHosts =
              [ (pkgs.callPackage ../packages/firefox-profile-switcher-connector.nix { }) ];
            extraPolicies = { ExtensionSettings = { }; };
          };

        in
        {
          enable = true;
          package = firefox-package;
          nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];

          preferences =
            {
              "browser.fullscreen.autohide" = false;
              "pdfjs.defaultZoomValue" = "page-fit";
            };
        };

      # Enable plymouth bootanimation
      boot.plymouth.enable = true;

    })
    (lib.mkIf cfg.arctis9.enable {
      # Arctis 9
      services.udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12c2", TAG+="uaccess"
      '';
      environment.systemPackages = with pkgs; [ headsetcontrol ];

    })
    (lib.mkIf cfg.flatpak.enable {
      services.flatpak.enable = true;
      # Ugly hack to add remote
      systemd.user.services."flatpak-remote-add" =
        let
          name = "flathub";
          location = builtins.fetchurl {
            url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
            sha256 =
              "sha256:0fm0zvlf4fipqfhazx3jdx1d8g0mvbpky1rh6riy3nb11qjxsw9k";
          };
        in
        {
          wantedBy = [ "default.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart =
              "/run/current-system/sw/bin/flatpak remote-add --user --if-not-exists ${name} ${location}";
          };
        };

      # Flatpak workarounds

      system.fsPackages = [ pkgs.bindfs ];
      fileSystems =
        let
          mkRoSymBind = path: {
            device = path;
            fsType = "fuse.bindfs";
            options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
          };
          aggregatedIcons = pkgs.buildEnv {
            name = "system-icons";
            paths = with pkgs; [
              libsForQt5.breeze-qt5 # for plasma
              gnome.gnome-themes-extra
            ];
            pathsToLink = [ "/share/icons" ];
          };
          aggregatedFonts = pkgs.buildEnv {
            name = "system-fonts";
            paths = config.fonts.packages;
            pathsToLink = [ "/share/fonts" ];
          };
        in
        {
          "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
          "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
        };

      fonts = {
        fontDir.enable = true;
      };

    })
    (lib.mkIf cfg.gaming.enable {
      environment.systemPackages = with pkgs; [
        legendary-gl
        wineWowPackages.stable
        dxvk
        heroic
        gamescope
        obs-studio
        webcord
        protonup-qt
      ];

      #Steam
      programs.steam = {
        enable = true;
        remotePlay.openFirewall =
          true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall =
          true; # Open ports in the firewall for Source Dedicated Server
      };

    })
    (lib.mkIf cfg.gaming.g29.enable {
      environment.systemPackages = [
        pkgs.oversteer
        pkgs.at
        g29init
      ];
      services.atd.enable = true;

      hardware.new-lg4ff.enable = true;
      services.udev.packages = with pkgs; [ oversteer ];
      #TODO try with a systemd service, https://unix.stackexchange.com/questions/436666/run-service-after-ttyusb0-becomes-available
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="hid", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c24f", RUN+="${pkgs.at}/bin/at -M -f ${g29init}/bin/g29init now"
      '';

    })
    (lib.mkIf cfg.matlab.enable {
      environment.systemPackages = [
        matlab-wrapped
        pkgs.matlab-mlint
        pkgs.matlab-mex
      ];
      nixpkgs.overlays = [ inputs.nix-matlab.overlay ];
    })
    (lib.mkIf cfg.blacklistnvidia.enable {
      boot.extraModprobeConfig = ''
        blacklist nouveau
        options nouveau modeset=0
      '';

      services.udev.extraRules = ''
        # Remove NVIDIA USB xHCI Host Controller devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA USB Type-C UCSI devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA Audio devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA VGA/3D controller devices
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
      '';
      boot.blacklistedKernelModules =
        [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
    })
  ];
}
