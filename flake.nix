{
  description = "Arnau NixOS configs";

  inputs = {
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixpkgs-stable.url = "nixpkgs/nixos-23.05";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    hyprland.url = "github:hyprwm/Hyprland";

    nix-matlab.url = "gitlab:doronbehar/nix-matlab";

    private.url = "git+ssh://git@github.com/Toomoch/nixos-config-private.git";
  };

  outputs = inputs@{ self, nixpkgs-unstable, home-manager, nixpkgs-stable, home-manager-stable, sops-nix, deploy-rs, hyprland, nix-matlab, private, ... }:
    let
      system = "aarch64-linux";
    in
    {
      homeConfigurations = {
        "arnau" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs-unstable { system = "x86_64-linux"; };

          modules = [
            ./home/arnau
          ];

        };
      };

      homeManagerModules = {
        default = import ./home/arnau;
        sway = import ./home/arnau/sway;
        desktop = import ./home/arnau/desktop.nix;
      };

      nixosModules.common = import ./system/modules { inherit inputs; }; 

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
                  sops-nix.homeManagerModules.sops
                ];
              };
            }
            sops-nix.nixosModules.sops
          ];
        };

        ps42 = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./system/machine/ps42
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs; };
                users.arnau.imports = [
                  ./home/arnau/machine/ps42.nix
                  sops-nix.homeManagerModules.sops
                ];
              };
            }
            sops-nix.nixosModules.sops
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
            sops-nix.nixosModules.sops
          ];
        };

        h81 = nixpkgs-stable.lib.nixosSystem rec {
          system = "x86_64-linux";

          specialArgs = {
            pkgs-unstable = import nixpkgs-unstable {
              system = system; # refer the `system` parameter form outer scope recursively
              config.permittedInsecurePackages = [
                "nodejs-16.20.2"
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
                  sops-nix.homeManagerModules.sops
                ];
              };
            }
            sops-nix.nixosModules.sops
          ];
        };
        rpi3 = nixpkgs-stable.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./system/machine/rpi3
            home-manager-stable.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs; };
                users.arnau.imports = [
                  ./home/arnau/machine/rpi3.nix
                ];
              };
            }
            sops-nix.nixosModules.sops
          ];
        };
      };

      # deploy-rs node configuration
      deploy.nodes = {
        h81 =
          let
            # use cache for building deploy-rs aarch64
            system = "x86_64-linux";
            # Unmodified nixpkgs
            pkgs = import nixpkgs-unstable { inherit system; };
            # nixpkgs with deploy-rs overlay but force the nixpkgs package
            deployPkgs = import nixpkgs-unstable {
              inherit system;
              overlays = [
                deploy-rs.overlay
                (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
              ];
            };
          in
          {
            hostname = "h81.casa.lan";
            profiles.system = {
              sshUser = "arnau";
              sshOpts = [ "-t" ];
              magicRollback = false;
              path =
                deployPkgs.deploy-rs.lib.activate.nixos
                  self.nixosConfigurations.h81;
              user = "root";
            };
          };
        rpi3 =
          let
            # use cache for building deploy-rs aarch64
            system = "aarch64-linux";
            # Unmodified nixpkgs
            pkgs = import nixpkgs-unstable { inherit system; };
            # nixpkgs with deploy-rs overlay but force the nixpkgs package
            deployPkgs = import nixpkgs-unstable {
              inherit system;
              overlays = [
                deploy-rs.overlay
                (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
              ];
            };
          in
          {
            hostname = "rpi3.lan";
            profiles.system = {
              sshUser = "arnau";
              sshOpts = [ "-t" ];
              magicRollback = false;
              path =
                deployPkgs.deploy-rs.lib.activate.nixos
                  self.nixosConfigurations.rpi3;
              user = "root";
            };
          };
      };
    };
}
