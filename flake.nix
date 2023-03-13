{
  description = "Arnau NixOS configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {

      b450-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./system/machine/b450/hardware-configuration.nix
          ./system
          ./system/machine/b450
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.arnau.imports = [
                ./home/arnau
              ];
            };
          }
        ];
      };

      ps42-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./system/machine/ps42/hardware-configuration.nix
          ./system
          ./system/machine/ps42
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.arnau.imports = [
                ./home/arnau
              ];
            };
          }
        ];
      };

      vm-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./system/machine/vm/hardware-configuration.nix
          ./system
          ./system/machine/vm
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.arnau.imports = [
                ./home/arnau
              ];
            };
          }
        ];
      };
    };
  };
}
