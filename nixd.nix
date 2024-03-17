# .nixd.nix
{
  eval = {
    # Example target for writing a package.
    target = {
      args = [ "--expr" "with import <nixpkgs> { }; callPackage ./somePackage.nix { }" ];
      installable = "";
    };
    # Force thunks
    depth = 10;
  };
  formatting.command = "nixpkgs-fmt";
  options = {
    enable = true;
    target = {
      args = [ ];
      # Example installable for flake-parts, nixos, and home-manager

      # nixOS configuration
      installable = "/flakeref#nixosConfigurations.ps42.options";

    };
  };
}

