{ config, pkgs, lib, flake-root, private, secrets, ... }: {
  imports = [ ./hardware-configuration.nix ./disko.nix ./hass.nix ./jellyfin.nix ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "h81"; # Define your hostname.

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 4096; # Use 2048MiB memory.
      cores = 4;
    };
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "zstorage" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "e0684fdb";

  custom.common.systemd-boot.enable = true;
  custom.homelab = {
    enable = true;
    serviceDataDir = "/zstorage/data";
  };
  custom.telegraf.enable = true;
  custom.homepage-dashboard.enable = true;
  custom.immich.enable = true;
  custom.nextcloud.enable = false;
  custom.smb = {
    enable = true;
    userShares = {
      enable = true;
      baseDir = "/zstorage/share/personal";
      users = secrets.smbUsers;
    };
  };
  custom.grafana.enable = true;
  custom.vm.docker.enable = true;
  custom.vm.libvirtd.enable = true;
  custom.vm.podman.enable = true;

  # enable sanoid templates
  custom.homelab.sanoid.enable = true;
  services.sanoid.datasets = {
    "zstorage/share".use_template = [ "storage" ];
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };
  services.networkd-dispatcher = {
    enable = true;
    rules."50-tailscale" = {
      onState = [ "routable" ];
      script = ''
        #!${pkgs.runtimeShell}
        ${lib.getExe pkgs.ethtool} -K enp3s0 rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };

  security.polkit.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver =
      pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs;
      [
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
