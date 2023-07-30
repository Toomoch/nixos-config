{
  description = "Arnau NixOS configs";

  inputs = {
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    fufexan.url = "github:fufexan/dotfiles";
    fufexan.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixpkgs-stable.url = "nixpkgs/nixos-23.05";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = inputs@{ self, nixpkgs-unstable, home-manager, nixpkgs-stable, home-manager-stable, ... }: {
    nixosConfigurations = {

      b450 = nixpkgs-unstable.lib.nixosSystem {
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

      ps42 = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";

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

      vm = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./system/machine/vm
          home-manager-stable.nixosModules.home-manager
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

      h81 = nixpkgs-stable.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            system = system; # refer the `system` parameter form outer scope recursively
            config.permittedInsecurePackages = [
              "nodejs-16.20.1"
            ];
          };
          inherit inputs;
        };

        modules = [
          ./system/machine/h81
          home-manager-stable.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.arnau.imports = [
                ./home/arnau/machine/h81.nix
              ];
            };
          }
        ];
      };
    };
  };
}
