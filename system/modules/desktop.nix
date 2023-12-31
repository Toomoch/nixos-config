{ inputs, config, lib, pkgs, ... }:
with lib; let
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
    enable = mkEnableOption ("Whether to enable common stuff for desktop systems");
    arctis9.enable = mkEnableOption ("Whether to enable Arctis9 support");
    flatpak.enable = mkEnableOption ("Whether to enable Flatpak support");
    gaming.enable = mkEnableOption ("Whether to enable gaming stuff");
    gaming.g29.enable = mkEnableOption ("Whether to enable G29 wheel support");
    matlab.enable = mkEnableOption ("Whether to enable MATLAB");
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Arctis 9
      #environment.systemPackages = with pkgs; [
      #] ++ optional cfg.arctis9.enable "headsetcontrol";
      #
      #services.udev.extraRules = optionalString cfg.arctis9.enable ''
      #  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12c2", TAG+="uaccess"'';

      nixpkgs.config.permittedInsecurePackages = [
        "electron-24.8.6"
      ];

      programs.nix-ld.enable = true;

      environment.systemPackages = with pkgs; [
        vulkan-tools
        glxinfo
        libva-utils
      ];

      # Printing
      services.printing.enable = true;
      services.avahi.enable = true;
      # for a WiFi printer
      services.avahi.openFirewall = true;

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
      programs.firefox = {
        enable = true;
        preferences = {
          "browser.fullscreen.autohide" = false;
        };
      };

      # Enable plymouth bootanimation
      boot.plymouth.enable = true;

    })
    (mkIf cfg.arctis9.enable {
      # Arctis 9
      services.udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12c2", TAG+="uaccess"
      '';
      environment.systemPackages = with pkgs; [
        headsetcontrol
      ];

    })
    (mkIf cfg.flatpak.enable {
      services.flatpak.enable = true;
      # Ugly hack to add remote
      system.activationScripts = {
        flathub = ''
          /run/current-system/sw/bin/flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        '';
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
          aggregatedFonts = pkgs.buildEnv {
            name = "system-fonts";
            paths = config.fonts.packages;
            pathsToLink = [ "/share/fonts" ];
          };
        in
        {
          # Create an FHS mount to support flatpak host icons/fonts
          "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
          "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
        };
    })
    (mkIf cfg.gaming.enable {
      environment.systemPackages = with pkgs; [
        legendary-gl
        wineWowPackages.stable
        dxvk
        heroic
        gamescope
        obs-studio
        webcord
        protonup-qt
        cemu
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
    (mkIf cfg.gaming.g29.enable {
      environment.systemPackages = with pkgs; [
        oversteer
        at
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
    (mkIf cfg.matlab.enable {
      environment.systemPackages = with pkgs; [
        matlab-wrapped
        matlab-mlint
        matlab-mex
      ];

      nixpkgs.overlays = [
        inputs.nix-matlab.overlay
      ];



    })


  ];
}
