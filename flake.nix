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
      secrets = "${private}/secrets/";
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
    in
    {
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
      });

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

      nixosConfigurations =
        let
          defaultModules = [
            self.nixosModules.common
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
          extraSpecialArgs = { inherit inputs; };
        in
        {
          b450 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
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
            ];
          };

          ps42 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              ./system/machine/ps42
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  inherit extraSpecialArgs;
                  users.arnau.imports = [
                    ./home/arnau/machine/ps42.nix
                    sops-nix.homeManagerModules.sops
                  ];
                };
              }
            ];
          };

          vm = nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              ./system/machine/vm
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
            ];
          };

          "${builtins.readFile (secrets + "/hostname")}" = nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              (workpath + "/work.nix")
              (workpath + "/work-hardware-configuration.nix")
              ./system/users/arnau.nix
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

            modules = defaultModules ++ [
              ./system/machine/h81
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
            ];
          };

          rpi3 = nixpkgs-stable.lib.nixosSystem {
            system = "aarch64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              ./system/machine/rpi3
              "${nixpkgs-stable}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ];
          };

          cp6230 = nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              ./system/machine/cp6230
            ];
          };

          l50 = nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              ./system/machine/l50
            ];
          };
        };

      # deploy-rs node configuration stolen from https://github.com/LongerHV/nixos-configuration
      deploy.nodes =
        let
          mkDeployConfig = hostname: configuration: {
            inherit hostname;
            profiles.system =
              let
                inherit (configuration.config.nixpkgs.hostPlatform) system;
              in
              {
                path = deploy-rs.lib."${system}".activate.nixos configuration;
                sshUser = "arnau";
                user = "root";
                sshOpts = [ "-t" ];
                magicRollback = false; # Disable because it breaks remote sudo :<
              };
          };
        in
        {
          h81 = mkDeployConfig "h81.casa.lan" self.nixosConfigurations.h81;
          rpi3 = mkDeployConfig "rpi3.casa.lan" self.nixosConfigurations.rpi3;
          cp6230 = mkDeployConfig "cp6230.casa.lan" self.nixosConfigurations.cp6230;
          l50 = mkDeployConfig "l50.casa.lan" self.nixosConfigurations.l50;
        };
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
