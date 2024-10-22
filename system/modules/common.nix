{ inputs, config, lib, pkgs, nixpkgs, secrets, ... }:
let
  cfg = config.common;
in
{
  options.common = {
    enable = lib.mkEnableOption "Whether to enable common stuff";
    systemd-boot.enable = lib.mkEnableOption "Whether to enable x86 bootloader";
    cloud.enable = lib.mkEnableOption "Whether to enable cloud specific settings";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      nix = {
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = true;
          builders-use-substitutes = true;
        };
        registry.nixpkgs.flake = nixpkgs;
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 15d";
          persistent = true;
        };
        distributedBuilds = false;
        buildMachines = [{
          hostName = "h81";
          sshUser = secrets.hosts.h81.user;
          publicHostKey = secrets.hosts.h81.pubKeyBase64;
          sshKey = "${config.users.users.${secrets.hosts.${config.networking.hostName}.user}.home}/.ssh/id_ed25519";
          system = "x86_64-linux";
          protocol = "ssh-ng";
          # default is 1 but may keep the builder idle in between builds
          maxJobs = 3;
          # how fast is the builder compared to your local machine
          speedFactor = 2;
          supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
          mandatoryFeatures = [ ];
        }];
      };

      systemd.network.enable = true;
      networking.useNetworkd = true;

      # Set your time zone.
      time.timeZone = "Europe/Madrid";

      # Select internationalisation properties.
      i18n = {
        supportedLocales = [ "en_GB.UTF-8/UTF-8" "ca_ES.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_NUMERIC = "ca_ES.UTF-8";
          LC_TIME = "ca_ES.UTF-8";
          LC_MONETARY = "ca_ES.UTF-8";
          LC_PAPER = "ca_ES.UTF-8";
          LC_NAME = "ca_ES.UTF-8";
          LC_ADDRESS = "ca_ES.UTF-8";
          LC_TELEPHONE = "ca_ES.UTF-8";
          LC_MEASUREMENT = "ca_ES.UTF-8";
        };
      };

      # Configure keymap in X11
      services.xserver = {
        xkb.layout = "es";
        xkb.variant = "cat";
      };

      # Configure console keymap
      console = {
        font = "ter-124b";
        keyMap = "es";
        packages = with pkgs; [
          terminus_font
        ];
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        wget
        pciutils
        fastfetch
        xdg-utils
        usbutils
        lm_sensors
        htop
        just
        dig
        iperf3
      ];

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;
      programs.ssh = { startAgent = true; enableAskPassword = true; askPassword = "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass"; };

      # Enable mosh
      programs.mosh.enable = true;

      #Allow all VPN traffic routing
      networking.firewall.checkReversePath = "loose";

    })
    (lib.mkIf cfg.systemd-boot.enable {
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot.configurationLimit = 20;

    })
    (lib.mkIf cfg.cloud.enable {
      services.fail2ban.enable = true;
      services.openssh.settings.PasswordAuthentication = false;
    })

  ];
}
