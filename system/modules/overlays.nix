{ inputs, config, pkgs-unstable, agenix-rekey,  ... }:
{
  # homepage-dashboard from unstable
  #disabledModules = [
  #  "services/misc/homepage-dashboard.nix"
  #];

  #imports = [
  #  "${inputs.nixpkgs}/nixos/modules/services/misc/homepage-dashboard.nix"
  #];

  # openvscode-server from unstable
  nixpkgs.overlays = [
    agenix-rekey.overlays.default
  ];
}
