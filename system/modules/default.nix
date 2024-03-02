inputs: { sops-nix, ...}:
{
  imports = [
    ./desktop.nix
    ./de.nix
    ./sway.nix
    ./virtualisation.nix
    ./common.nix
    ./homelab.nix
  ];
}
