{ config, pkgs, lib, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15d";
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;


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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.arnau = {
    isNormalUser = true;
    description = "Arnau";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    vulkan-tools
    pciutils
    neofetch
    glxinfo
    xdg-utils
    usbutils
    libva-utils
    rclone
  ];

  fonts.fonts = with pkgs; [
    rubik
    fira-code
    fira-code-symbols
    font-awesome
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  fonts.fontconfig = {
    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
      monospace = [ "Noto Sans Mono" ];
    };
  };

  #List of services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  #Allow all VPN traffic routing
  networking.firewall.checkReversePath = "loose";

  # Enable plymouth bootanimation
  boot.plymouth.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
