{
  description = "Arnau NixOS configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {

      ps42-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        specialArgs = { inherit inputs; };
        
        modules = [
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

      b450-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        specialArgs = { inherit inputs; };
        
        modules = [
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
    };
  };
}
