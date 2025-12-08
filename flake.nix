{
  description = "Arnau NixOS configs";

  inputs = {
    self.submodules = true;

    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixpkgs-stable.url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko-stable = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "";
    };

    wirenix.url = "sourcehut:~msalerno/wirenix";
    mnw.url = "github:Gerg-L/mnw";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixpkgs-stable,
      home-manager-stable,
      deploy-rs,
      nixvim,
      disko-stable,
      disko,
      agenix,
      agenix-rekey,
      wirenix,
      mnw,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # specialArgs
      flake-root = ./.;
      private = /${flake-root}/private;

      stable = {
        nixpkgs = nixpkgs-stable;
        home-manager = home-manager-stable;
        disko = disko-stable;
        agenix = agenix;
      };

      unstable = {
        nixpkgs = nixpkgs;
        home-manager = home-manager;
        disko = disko;
        agenix = agenix;
      };

      hosts = [
        {
          host = "oracle1";
          branch = stable;
          hm = false;
        }
        {
          host = "ps42";
          branch = stable;
          hm = true;
        }
        {
          host = "h81";
          branch = stable;
          hm = true;
        }
        {
          host = "b450";
          branch = stable;
          hm = true;
        }
        {
          host = "rpi3";
          branch = stable;
          hm = false;
        }
        {
          host = "ampere";
          branch = stable;
          hm = false;
        }
        {
          host = "potato";
          branch = stable;
          hm = false;
        }
        {
          host = "x550";
          branch = stable;
          hm = false;
        }
        {
          host = builtins.readFile /${private}/secrets/plain/workhostname;
          branch = stable;
          hm = true;
          host-folder = "work";
        }
        {
          host = "vm";
          branch = stable;
          hm = true;
        }
      ];

      forAllSystems =
        function: nixpkgs':
        nixpkgs'.lib.genAttrs nixpkgs'.lib.systems.flakeExposed (
          system:
          function (import nixpkgs' {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              outputs.overlays.additions
              outputs.overlays.modifications
              outputs.overlays.unstable-packages
            ];
          }) system
        );

      mkColmenaHive =
        nixpkgs: nodeDeployments:
        let
          confs = inputs.self.nixosConfigurations;
          colmenaConf = {
            meta = {
              inherit nixpkgs;
              nodeNixpkgs = builtins.mapAttrs (_name: value: value.pkgs) confs;
              nodeSpecialArgs = builtins.mapAttrs (_name: value: value._module.specialArgs) confs;
            };
          }
          // builtins.mapAttrs (nodeName: value: {
            imports = value._module.args.modules;
            deployment = nodeDeployments.${nodeName} or { };
          }) confs;
        in
        inputs.colmena.lib.makeHive colmenaConf;

    in
    {
      colmenaHive = mkColmenaHive (import nixpkgs { system = "x86_64-linux"; }) {
        ps42 = {
          allowLocalDeployment = true;
          targetHost = null;
        };
        h81 = {
          targetHost = "h81";
          buildOnTarget = true;
          targetUser = "arnau";
        };
        b450 = {
          allowLocalDeployment = true;
        };
        ampere = {
          targetHost = "ampere";
          buildOnTarget = true;
          targetUser = "arnau";
        };
        oracle1 = {
          targetHost = "oracle1";
          targetUser = "arnau";
        };
      };
      # Import every package found in the attr pkgs from ./pkgs/default.nix
      packages = forAllSystems (pkgs: system: import ./pkgs { inherit pkgs nixvim mnw; }) nixpkgs-stable;
      nixosModules.common = import ./modules/nixos;
      nixosModules.private = import /${private}/modules/nixos;
      homeManagerModules.common = import ./modules/home-manager;
      overlays = import ./overlays { inherit inputs nixvim mnw; };

      homeConfigurations = {
        "arnau" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          modules = [
            ./home
            ./home/arnau.nix
          ];
        };
      };

      nixosConfigurations =
        let
          defaultModules = host: branch: [
            self.nixosModules.common
            self.nixosModules.private
            branch.disko.nixosModules.disko
            branch.agenix.nixosModules.default
            agenix-rekey.nixosModules.default
            wirenix.nixosModules.default
            ./hosts/${host}
            {
              nix.registry.nixpkgs-unstable.flake = nixpkgs; # Add nixpkgs-unstable to registry
            }
          ];

          mkHostConfig =
            {
              host,
              branch,
              hm,
              host-folder ? host,
              ...
            }:
            {
              name = host;
              value =
                let # surely theres a better way of doing this
                  specialArgs = {
                    inherit
                      inputs
                      flake-root
                      private
                      self
                      outputs
                      ;
                  };
                in
                branch.nixpkgs.lib.nixosSystem {
                  inherit specialArgs;
                  modules =
                    defaultModules host-folder branch
                    ++ branch.nixpkgs.lib.optionals hm [
                      branch.home-manager.nixosModules.home-manager
                      {
                        home-manager = {
                          useGlobalPkgs = true;
                          extraSpecialArgs = specialArgs;
                          users.arnau.imports = [ self.homeManagerModules.common ];
                        };
                      }
                    ]
                    ++ branch.nixpkgs.lib.optional (builtins.pathExists /${private}/hosts/${host}) /${private}/hosts/${host};
                  # Include private host config
                };
            };

          autoMachineConfigs = map mkHostConfig hosts;

          machineConfigs = autoMachineConfigs ++ [ ];
        in
        builtins.listToAttrs machineConfigs;

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
      };

      # deploy-rs node configuration stolen from https://github.com/LongerHV/nixos-configuration
      deploy.nodes =
        let
          mkDeployConfig = hostname: configuration: interactiveSudo: remoteBuild: {
            inherit hostname interactiveSudo remoteBuild;
            profiles.system =
              let
                inherit (configuration.config.nixpkgs.hostPlatform) system;
              in
              {
                path = deploy-rs.lib."${system}".activate.nixos configuration;
                sshUser = "arnau";
                user = "root";
                #interactiveSudo = true;
                #sshOpts = ["-A"];
                sshOpts = [
                  "-o"
                  "ProxyCommand=none"
                ];
                magicRollback = true;
              };
          };
        in
        {
          h81 = mkDeployConfig "h81" self.nixosConfigurations.h81 false true;
          rpi3 = mkDeployConfig "rpi3" self.nixosConfigurations.rpi3 false false;
          l50 = mkDeployConfig "" self.nixosConfigurations.l50 true false;
          oracle1 = mkDeployConfig "oracle1" self.nixosConfigurations.oracle1 false false;
          ampere = mkDeployConfig "ampere" self.nixosConfigurations.oracle2 false true;
        };
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
