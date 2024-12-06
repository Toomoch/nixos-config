inputs: { sops-nix, ...}:
{
  imports = [
    ./desktop.nix
    ./de.nix
    ./virtualisation.nix
    ./common.nix
    ./homelab
    ./secrets.nix
    ./overlays.nix
    ./vfio.nix
    ./waylandWindowManagers.nix
  ];
}
