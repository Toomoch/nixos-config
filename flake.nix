{
  description = "Arnau NixOS configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
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

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #hyprland.url = "github:hyprwm/Hyprland";

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #ags.url = "github:Aylur/ags";
    #matugen.url = "github:InioX/matugen";

  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixpkgs-stable, home-manager-stable, deploy-rs, nixvim, disko-stable, disko, nix-on-droid, agenix, agenix-rekey, ... }:
    let
      flake-root = ./.;
      private = /${flake-root}/private;
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
        ]
          (system: function nixpkgs.legacyPackages.${system});

      secrets = import /${private}/secrets/secrets.nix;

      stable = { nixpkgs = nixpkgs-stable; home-manager = home-manager-stable; disko = disko-stable; agenix = agenix; };
      unstable = { nixpkgs = nixpkgs; home-manager = home-manager; disko = disko; agenix = agenix; };

      hosts = [
        { host = "oracle1"; arch = "x86_64-linux"; branch = stable; hm = false; }
        { host = "ps42"; arch = "x86_64-linux"; branch = stable; hm = true; }
        { host = "h81"; arch = "x86_64-linux"; branch = stable; hm = true; }
        { host = "b450"; arch = "x86_64-linux"; branch = stable; hm = true; }
        { host = "rpi3"; arch = "aarch64-linux"; branch = stable; hm = false; }
        { host = "oracle2"; arch = "aarch64-linux"; branch = stable; hm = false; }
        { host = secrets.work.hostName; arch = "x86_64-linux"; branch = stable; hm = true; }
        { host = "vm"; arch = "x86_64-linux"; branch = stable; hm = true; }

      ];
    in
    {
      packages = forAllSystems (pkgs: {
        default = import ./shell.nix { inherit pkgs; };
      });
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        extraSpecialArgs =
          let
            nixpkgs = nixpkgs-stable;
          in
          { inherit inputs nixpkgs secrets; };
        pkgs = import nixpkgs-stable { system = "aarch64-linux"; };
        modules = [
          ./nix-on-droid
          {
            home-manager = {
              config.imports = [ ];
              extraSpecialArgs = { inherit inputs secrets; };
            };
          }
        ];
        home-manager-path = home-manager-stable.outPath;
      };


      homeConfigurations = {
        "arnau" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          modules = [
            ./home
            ./home/arnau.nix
          ];
        };
      };

      nixosModules.common = import ./system/modules { inherit inputs; };

      nixosConfigurations =
        let
          defaultModules = host: branch: [
            self.nixosModules.common
            branch.disko.nixosModules.disko
            branch.agenix.nixosModules.default
            agenix-rekey.nixosModules.default
            ./system/machine/${host}
          ];

          mkHostConfig = { host, arch, branch, hm, ... }: {
            name = host;
            value =
              let # surely theres a better way of doing this
                host-folder = secrets.hosts.${host}.hostFolder;
                pkgs-unstable = import nixpkgs { system = arch; };
                specialArgs = { inherit pkgs-unstable inputs secrets flake-root private agenix-rekey; nixpkgs = branch.nixpkgs; nixpkgs-unstable = nixpkgs; };
              in
              branch.nixpkgs.lib.nixosSystem {
                system = arch;
                inherit specialArgs;
                modules = defaultModules host-folder branch ++ branch.nixpkgs.lib.optional (branch == stable) ./system/modules/stable-overlays.nix
                  ++ branch.nixpkgs.lib.optionals hm [
                  branch.home-manager.nixosModules.home-manager
                  {
                    home-manager =
                      let
                        user = secrets.hosts.${host}.user;
                      in
                      {
                        useGlobalPkgs = true;
                        extraSpecialArgs = specialArgs;
                        users.${user}.imports = [
                          ./home/machine/${host-folder}.nix
                        ] ++ branch.nixpkgs.lib.optional (branch == unstable) ./home/unstable.nix;
                      };
                  }
                ];
              };
          };

          autoMachineConfigs = map mkHostConfig hosts;

          machineConfigs = autoMachineConfigs ++ [ ];
        in
        builtins.listToAttrs machineConfigs;


      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nodes = self.nixosConfigurations;
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
                magicRollback = true;
              };
          };
        in
        {
          h81 = mkDeployConfig "h81" self.nixosConfigurations.h81 false true;
          rpi3 = mkDeployConfig "rpi3" self.nixosConfigurations.rpi3 false false;
          l50 = mkDeployConfig "" self.nixosConfigurations.l50 true false;
          oracle1 = mkDeployConfig "oracle1" self.nixosConfigurations.oracle1 false false;
          oracle2 = mkDeployConfig "oracle2" self.nixosConfigurations.oracle2 false true;
        };
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
