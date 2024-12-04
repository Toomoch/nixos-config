{ inputs, config, pkgs, pkgs-unstable, agenix-rekey,  ... }:
let
  river-overlay = self: super: {
    # override derivation attributes
    river = super.river.overrideAttrs (old: {
      # add `makeWrapper` to existing dependencies
      buildInputs = old.buildInputs ++ [ pkgs.makeWrapper ];
      # wrap the binary in a script where the appropriate env var is set
      postInstall = old.postInstall or "" + ''
        wrapProgram "$out/bin/river" --set XDG_SESSION_TYPE wayland --set XDG_CURRENT_DESKTOP river --set XDG_SESSION_DESKTOP river
      '';
    });
  };
  # XDG_SESSION_TYPE = "wayland";
  #    XDG_CURRENT_DESKTOP = "river";
  #    XDG_SESSION_DESKTOP = "river";
in
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
