{ config, lib, pkgs, nixpkgs, ... }:
{
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim # or some other editor, e.g. nano or neovim
    openssh
    mosh
    git
    fastfetch
    zsh
    procps
    # Some common stuff that people expect to have
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    curl
    just
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    registry.nixpkgs.flake = nixpkgs;
  };


  home-manager = {
    config = ../home/machine/nix-on-droid.nix;
    useGlobalPkgs = true;
    backupFileExtension = "hm-bak";
  };

  # Set your time zone
  time.timeZone = "Europe/Madrid";

  user.shell = "${pkgs.zsh}/bin/zsh";
}

