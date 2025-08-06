{
  inputs,
  config,
  lib,
  pkgs,
  nixpkgs,
  secrets,
  outputs,
  private,
  ...
}:
let
  cfg = config.custom.common;
  user = "${secrets.hosts.${config.networking.hostName}.user}";
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  options.custom.common = {
    enable = lib.mkEnableOption "Whether to enable common stuff";
    systemd-boot.enable = lib.mkEnableOption "Whether to enable systemd-boot bootloader";
    cloud.enable = lib.mkEnableOption "Whether to enable cloud specific settings";
    defaultUser.enable = lib.mkEnableOption "Whether to enable the default user with a configurable name";
    wol.enable = lib.mkEnableOption "Enable Wake On LAN via udev rules";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # populate branch name/commit hash
      system.configurationRevision = let self = inputs.self; in self.shortRev or self.dirtyShortRev or self.lastModified or "unknown";
      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
          builders-use-substitutes = true;
        };
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 15d";
          persistent = true;
        };
        distributedBuilds = false;
        buildMachines = [
          {
            hostName = "h81";
            sshUser = secrets.hosts.h81.user;
            publicHostKey = secrets.hosts.h81.pubKeyBase64;
            sshKey = "${
              config.users.users.${secrets.hosts.${config.networking.hostName}.user}.home
            }/.ssh/id_ed25519";
            system = "x86_64-linux";
            protocol = "ssh-ng";
            # default is 1 but may keep the builder idle in between builds
            maxJobs = 3;
            # how fast is the builder compared to your local machine
            speedFactor = 2;
            supportedFeatures = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];
            mandatoryFeatures = [ ];
          }
        ];
      };
      nixpkgs.overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
        inputs.agenix-rekey.overlays.default
      ];
      nixpkgs.flake.setNixPath = true;
      nixpkgs.flake.setFlakeRegistry = true;

      systemd.network.enable = true;
      networking.useNetworkd = true;

      # Set your time zone.
      time.timeZone = "Europe/Madrid";

      # Select internationalisation properties.
      i18n = {
        supportedLocales = [
          "en_GB.UTF-8/UTF-8"
          "ca_ES.UTF-8/UTF-8"
          "en_US.UTF-8/UTF-8"
        ];
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

      environment.etc.inputrc.text = ''
        $include ${nixpkgs.outPath + "/nixos/modules/programs/bash/inputrc"}
        set editing-mode vi
        set keyseq-timeout 50
        set show-mode-in-prompt on
        set vi-cmd-mode-string \1\e[34;1m\2[N] \1\e[0m\2
        set vi-ins-mode-string \1\e[32;1m\2[I] \1\e[0m\2
      '';

      # Configure console keymap
      # https://github.com/NixOS/nixpkgs/issues/257904
      console = {
        font = "${pkgs.terminus_font}/share/consolefonts/ter-124b.psf.gz";
        useXkbConfig = true;
        # packages = with pkgs; [ terminus_font ];
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
        tree
        unzip
        borgbackup
        rsync
        tmux
        traceroute
        mtr
      ];

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;
      programs.ssh = {
        startAgent = true;
        enableAskPassword = true;
        askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
      };

      # Enable mosh
      programs.mosh.enable = true;

      #Allow all VPN traffic routing
      networking.firewall.checkReversePath = "loose";

      # nixos-rebuild-ng
      system.rebuild.enableNg = true;

    })
    (lib.mkIf cfg.systemd-boot.enable {
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot.configurationLimit = 10;

    })
    (lib.mkIf cfg.defaultUser.enable {

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.${user} = {
        isNormalUser = true;
        description = "Arnau";
        extraGroups = ifTheyExist [
          "networkmanager"
          "wheel"
          "adbusers"
          "libvirtd"
          "docker"
          "dialout"
        ];
        packages = with pkgs; [ ];

        initialHashedPassword = builtins.readFile /${private}/secrets/plain/inithashpass;
        openssh.authorizedKeys.keys = secrets.authlist config.networking.hostName;
        shell = pkgs.bash;
      };
      programs.starship.enable = true;
      programs.fzf.fuzzyCompletion = true;
      programs.fzf.keybindings = true;

      security.pam = {
        services = {
          sudo.u2fAuth = true;
          login.u2fAuth = true;
          greetd.u2fAuth = true;
          sudo.rssh = true;
        };
        u2f.settings = {
          enable = true;
          cue = true;
          origin = "pam://arnau";
          authfile = config.age.secrets.u2f_keys.path;
        };
      };

      age.secrets.u2f_keys = {
        rekeyFile = /${private}/secrets/age/u2f_keys.age;
        mode = "444";
      };

      # pam_rssh
      security.pam.rssh.enable = true;

      # Disabled because for new deployments we can't decrypt the password, for example pi3 sdcard
      # age.secrets.passwordfile-arnau.rekeyFile = "${private}/secrets/age/password.age";

      nix.settings.trusted-users = [ "${user}" ];
    })
    (lib.mkIf cfg.cloud.enable {
      services.fail2ban = {
        enable = true;
        maxretry = 5;
        bantime-increment.enable = true;
      };
      # Harden SSH
      services.openssh = {
        settings = {
          X11Forwarding = false;
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          MaxSessions = 2;
          MaxAuthTries = 3;
          ClientAliveCountMax = 2;
          AllowTcpForwarding = "no";
          AllowAgentForwarding = "yes";
          AllowStreamLocalForwarding = "no";
          AuthenticationMethods = "publickey";
          TCPKeepAlive = "no";
        };
      };
      boot.initrd = {
        availableKernelModules = [
          "virtio_net"
          "virtio_pci"
          "virtio_mmio"
          "virtio_blk"
          "virtio_scsi"
        ];
        kernelModules = [
          "virtio_balloon"
          "virtio_console"
          "virtio_rng"
        ];
      };
      boot.kernelParams = [
        # Disable auditing
        "audit=0"
        # Do not generate NIC names based on PCIe addresses (e.g. enp1s0, useless for VPS)
        # Generate names based on orders (e.g. eth0)
        "net.ifnames=0"
      ];
    })
    (lib.mkIf cfg.wol.enable {
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="net", NAME=="en*",, RUN+="${lib.getExe pkgs.ethtool} -s $name wol g"
      '';
    })

  ];
}
