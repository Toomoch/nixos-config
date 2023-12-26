{
  description = "Arnau NixOS configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-stable.url = "nixpkgs/nixos-23.11";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    #hyprland.url = "github:hyprwm/Hyprland";

    nix-matlab.url = "gitlab:doronbehar/nix-matlab";

    private.url = "git+ssh://git@github.com/Toomoch/nixos-config-private.git";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixpkgs-stable, home-manager-stable, sops-nix, deploy-rs, nix-matlab, private, ... }:
    let
      workpath = "${private}/system/machine/";
      workpathhome = "${private}/home/arnau";

    in
    {
      homeConfigurations = {
        "arnau" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };

          modules = [
            ./home/arnau
          ];

        };
      };

      homeManagerModules = {
        default = import ./home/arnau;
        sway = import ./home/arnau/sway;
        desktop = import ./home/arnau/desktop.nix;
        devtools = import ./home/arnau/devtools.nix;
      };

      nixosModules.common = import ./system/modules { inherit inputs; };
      nixosModules.homelab = import ./system/modules/homelab.nix;

      nixosConfigurations = {
        b450 = nixpkgs.lib.nixosSystem {

          system = "x86_64-linux";

          specialArgs = { inherit inputs; };

          modules = [
            ./system/machine/b450
            self.nixosModules.common
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

        ps42 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./system/machine/ps42
            self.nixosModules.common
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
            self.nixosModules.common
            home-manager-stable.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs; };
                users.arnau.imports = [
                  ./home/arnau/machine/vm.nix
                  sops-nix.homeManagerModules.sops
                ];
              };
            }
            sops-nix.nixosModules.sops
          ];
        };

        "${builtins.readFile (workpath + "/hostname")}" = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs; };

          modules = [
            (workpath + "/work.nix")
            (workpath + "/work-hardware-configuration.nix")
            self.nixosModules.common
            home-manager-stable.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs; };
                users.arnau.imports = [
                  self.homeManagerModules.default
                  self.homeManagerModules.sway
                  self.homeManagerModules.desktop
                  self.homeManagerModules.devtools
                  sops-nix.homeManagerModules.sops
                  workpathhome
                ];
              };
            }
            sops-nix.nixosModules.sops
          ];
        };

        h81 = nixpkgs-stable.lib.nixosSystem rec {
          system = "x86_64-linux";

          specialArgs = {
            pkgs-unstable = import nixpkgs {
              system = system; # refer the `system` parameter form outer scope recursively
              config.permittedInsecurePackages = [
                "nodejs-16.20.2"
              ];
              config.allowUnfree = true;
            };
            inherit inputs;
          };

          modules = [
            ./system/machine/h81
            self.nixosModules.common
            self.nixosModules.homelab
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

          specialArgs = { inherit inputs; };

          modules = [
            ./system/machine/rpi3
            self.nixosModules.common
            "${nixpkgs-stable}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
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
            pkgs = import nixpkgs { inherit system; };
            # nixpkgs with deploy-rs overlay but force the nixpkgs package
            deployPkgs = import nixpkgs {
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
            pkgs = import nixpkgs { inherit system; };
            # nixpkgs with deploy-rs overlay but force the nixpkgs package
            deployPkgs = import nixpkgs {
              inherit system;
              overlays = [
                deploy-rs.overlay
                (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
              ];
            };
          in
          {
            hostname = "rpi3.casa.lan";
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
