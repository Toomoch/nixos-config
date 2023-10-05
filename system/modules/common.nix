{ inputs, config, lib, pkgs, ... }:
with lib; let
  cfg = config.common;
in
{
  options.common = {
    enable = mkEnableOption ("Whether to enable common stuff");
    x86.enable = mkEnableOption ("Whether to enable x86 bootloader");
  };

  config = mkMerge [
    (mkIf cfg.enable {
      nix = {
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = true;
        };
      };

      # Enable networking
      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "Europe/Madrid";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_GB.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "ca_ES.UTF-8";
        LC_IDENTIFICATION = "ca_ES.UTF-8";
        LC_MEASUREMENT = "ca_ES.UTF-8";
        LC_MONETARY = "ca_ES.UTF-8";
        LC_NAME = "ca_ES.UTF-8";
        LC_NUMERIC = "ca_ES.UTF-8";
        LC_PAPER = "ca_ES.UTF-8";
        LC_TELEPHONE = "ca_ES.UTF-8";
        LC_TIME = "ca_ES.UTF-8";
      };

      # Configure keymap in X11
      services.xserver = {
        layout = "es";
        xkbVariant = "cat";
      };

      # Configure console keymap
      console.keyMap = "es";
      console.packages = [ pkgs.terminus_font ];
      console.font = "Lat2-Terminus16";

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        wget
        pciutils
        neofetch
        xdg-utils
        usbutils
      ];

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };
      fonts = {
        fontconfig.defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
          monospace = [ "Noto Sans Mono" ];
        };

        fonts = with pkgs; [
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

      #List of services that you want to enable:

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;

      # Enable mosh
      programs.mosh.enable = true;

      #Allow all VPN traffic routing
      networking.firewall.checkReversePath = "loose";

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

    })
    (mkIf cfg.x86.enable {
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot.configurationLimit = 20;

    })

  ];
}