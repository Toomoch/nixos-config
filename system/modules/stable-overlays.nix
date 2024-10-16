{ inputs, config, pkgs-unstable, ... }:
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
    (self: super: {
      firefoxpwa = pkgs-unstable.firefoxpwa;
      pam_rssh = pkgs-unstable.pam_rssh;
    })
  ];
}
