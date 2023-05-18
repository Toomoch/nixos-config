{
  description = "Arnau NixOS configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    eww.url = "github:fufexan/dotfiles";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {

      b450 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./system/machine/b450
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.arnau.imports = [
                ./home/arnau/machine/b450.nix
              ];
            };
          }
        ];
      };

      ps42 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./system/machine/ps42
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.arnau.imports = [
                ./home/arnau/machine/ps42.nix
              ];
            };
          }
        ];
      };

      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./system/machine/vm
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.arnau.imports = [
                ./home/arnau/machine/vm.nix
              ];
            };
          }
        ];
      };
    };
  };
}
