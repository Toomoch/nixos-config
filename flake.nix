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
    wrappers.url = "github:lassulus/wrappers";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixpkgs-stable,
      home-manager-stable,
      deploy-rs,
      disko-stable,
      disko,
      agenix,
      agenix-rekey,
      wirenix,
      mnw,
      wrappers,
      ...
    }:
    let
      # specialArgs
      flake-root = ./.;
      private = flake-root + "/private";

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
          privateConfigs = true;
        }
        {
          host = "ps42";
          branch = stable;
          hm = true;
          privateConfigs = true;
        }
        {
          host = "h81";
          branch = stable;
          hm = true;
          privateConfigs = true;
        }
        {
          host = "b450";
          branch = stable;
          hm = false;
          privateConfigs = true;
        }
        {
          host = "rpi3";
          branch = stable;
          hm = false;
          privateConfigs = true;
        }
        {
          host = "ampere";
          branch = stable;
          hm = false;
          privateConfigs = true;
        }
        {
          host = "potato";
          branch = stable;
          hm = false;
          privateConfigs = true;
        }
        {
          host = "x550";
          branch = stable;
          hm = false;
          privateConfigs = true;
        }
        {
          host = "smdltp451";
          branch = stable;
          hm = true;
          privateConfigs = true;
        }
        {
          host = "vm";
          branch = stable;
          hm = false;
        }
      ];

      forAllSystems =
        function: nixpkgs':
        nixpkgs'.lib.genAttrs nixpkgs'.lib.systems.flakeExposed (
          system: function (nixpkgs'.legacyPackages.${system}) system
        );

    in
    {
      packages = forAllSystems (pkgs: system: {
        help-blog = pkgs.callPackage ./packages/blog.nix { };
        nvim-mnw = mnw.lib.wrap pkgs ./modules/neovim.nix;
      }) nixpkgs;

      # do not use import keyword for pointing to modules, use the path
      nixosModules.common = ./modules/nixos;
      nixosModules.private = private + "/modules/nixos";
      homeModules.common = ./modules/home-manager;
      overlays = import ./overlays;

      # homeConfigurations = {
      #   "arnau" = home-manager.lib.homeManagerConfiguration {
      #     pkgs = import nixpkgs { system = "x86_64-linux"; };
      #     modules = [
      #       ./home
      #       ./home/arnau.nix
      #     ];
      #   };
      # };

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
              nix.registry.nixpkgs-unstable.flake = nixpkgs;
            }
          ];

          mkHostConfig =
            {
              host,
              branch,
              hm,
              privateConfigs ? false,
              ...
            }:
            {
              name = host;
              value =
                let
                  specialArgs = {
                    inherit
                      flake-root
                      private
                      self
                      ;
                  };
                in
                branch.nixpkgs.lib.nixosSystem {
                  inherit specialArgs;
                  modules =
                    defaultModules host branch
                    ++ branch.nixpkgs.lib.optionals hm [
                      branch.home-manager.nixosModules.home-manager
                      {
                        home-manager = {
                          useGlobalPkgs = true;
                          extraSpecialArgs = specialArgs;
                          users.arnau.imports = [ self.homeModules.common ];
                        };
                      }
                    ]
                    ++ branch.nixpkgs.lib.optional privateConfigs (private + "/hosts/${host}");
                  # Include private host config
                };
            };

        in
        builtins.listToAttrs (map mkHostConfig hosts);

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
      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
