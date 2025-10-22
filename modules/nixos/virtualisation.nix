{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.vm;
in
{
  options.custom.vm = {
    podman.enable = lib.mkEnableOption "Wheter to enable podman";
    docker.enable = lib.mkEnableOption "Wheter to enable Docker";
    libvirtd.enable = lib.mkEnableOption "Whether to enable libvirtd";
  };

  config = {
    environment.systemPackages =
      lib.optional cfg.podman.enable pkgs.podman-compose
      ++ lib.optional cfg.libvirtd.enable pkgs.win-virtio
      ++ lib.optional cfg.docker.enable pkgs.docker-compose;
    virtualisation = {
      podman = {
        enable = cfg.podman.enable;
        dockerCompat = false;
        defaultNetwork.settings.dns_enabled = true;
      };
      docker.enable = cfg.docker.enable;
    };

    virtualisation = {
      libvirtd = {
        enable = cfg.libvirtd.enable;
        qemu = {
          swtpm.enable = true;
          ovmf.packages = [
            pkgs.OVMFFull.fd
          ];
        };
      };
    };
  };

}
