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
          ./system/machine/b450
          ./system/machine/b450/hardware-configuration.nix
          ./system
          ./system/desktop.nix
          ./system/gaming.nix
          ./system/sway.nix
          ./system/virtualisation.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.arnau.imports = [
                ./home/arnau
                ./home/arnau/desktop.nix
                ./home/arnau/sway
              ];
            };
          }
        ];
      };

      ps42-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./system/machine/ps42
          ./system/machine/ps42/hardware-configuration.nix
          ./system
          ./system/desktop.nix
          ./system/sway.nix
          ./system/virtualisation.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.arnau.imports = [
                ./home/arnau
                ./home/arnau/desktop.nix
                ./home/arnau/sway
              ];
            };
          }
        ];
      };

      vm-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./system/machine/vm
          ./system/machine/vm/hardware-configuration.nix
          ./system
          ./system/desktop.nix
          ./system/gnome.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.arnau.imports = [
                ./home/arnau
                ./home/arnau/desktop.nix
              ];
            };
          }
        ];
      };
    };
  };
}
