{ sops-nix, ...}:
{
  imports = [
    ./homepage.nix
    ./homelab.nix
    ./homeassistant.nix
    ./immich.nix
    ./smb.nix
    ./nextcloud.nix
  ];
}
