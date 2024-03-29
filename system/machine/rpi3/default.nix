{ config, pkgs, lib, ... }:
{
  imports = [
    #./hardware-configuration.nix
    ../../users/arnau.nix
  ];

  networking.hostName = "rpi3"; # Define your hostname.

  environment.systemPackages = [
    pkgs.libraspberrypi
  ];

  common.enable = true;
  hardware.enableRedistributableFirmware = true;
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  boot.initrd.availableKernelModules = [ "usb_storage" ];

  # NixOS bruh moment https://github.com/NixOS/nixpkgs/issues/180175, afaik fixed in 24.05
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "172.16.0.1/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o enu1u1 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 172.16.0.0/24 -o enu1u1 -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      #privateKeyFile = "path to private key file";
      privateKey = "MC3Nv0ILy/0Iuu9qWLUE7kwrY2tOWjoVRu0/W61vhVE=";

      peers = [
        # List of allowed peers.
        {
          # Feel free to give a meaning full name
          # Public key of the peer (not a file path).
          name = "peer1";
          #priv: aCVJtii8N3wdodOV3gURv5+3uApCplK+I71U+uMrDmQ=
          publicKey = "cyTCCrWBsIoGPtS3oJcJuJhE7+PlU3eNk4ZWV3FabRg=";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = [ "172.16.0.1/32" ];
        }
      ];
    };
  };

  boot.kernelParams = [ "cma=32M" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
