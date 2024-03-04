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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    #hyprland.url = "github:hyprwm/Hyprland";
    
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    disko-stable.url = "github:nix-community/disko";
    disko-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    nix-matlab.url = "gitlab:doronbehar/nix-matlab";

    private.url = "git+ssh://git@github.com/Toomoch/nixos-config-private.git";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixpkgs-stable, home-manager-stable, sops-nix, deploy-rs, nix-matlab, private, nixvim, disko-stable, disko, ... }:
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

      nixosConfigurations =
        let
          defaultModules = host: disko: [
            self.nixosModules.common
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            ./system/machine/${host}
          ];

          defaultModulesHomeManager = home-manager: host: [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                inherit extraSpecialArgs;
                users.arnau.imports = defaultModulesHome host;
              };
            } 
          ];

          defaultModulesHome = host: [
            ./home/arnau/machine/${host}.nix
            sops-nix.homeManagerModules.sops
          ];
          specialArgs = { inherit inputs; };
          extraSpecialArgs = { inherit inputs; };

          mkHostConfig = { host, arch, nixpkgs, hm, home-manager, disko, ... }: {
            name = "${host}";
            value = nixpkgs.lib.nixosSystem {
              system = "${arch}";
              specialArgs = { inherit inputs; };
              modules = defaultModules host disko ++ nixpkgs.lib.optionals hm (defaultModulesHomeManager home-manager host);
            };
          };
          hosts = [
            { host = "oracle1"; arch = "x86_64-linux"; nixpkgs = nixpkgs; hm = false; home-manager = null; disko = disko; }
            { host = "ps42"; arch = "x86_64-linux"; nixpkgs = nixpkgs; hm = true; home-manager = home-manager; disko = disko; }
            { host = "h81"; arch = "x86_64-linux"; nixpkgs = nixpkgs-stable; hm = true; home-manager = home-manager-stable; disko = disko-stable; }
          ];
          autoMachineConfigs = map mkHostConfig hosts;

          machineConfigs = autoMachineConfigs ++ [ ];
        in
        builtins.listToAttrs machineConfigs;


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
                interactiveSudo = true;
                magicRollback = true;
              };
          };
        in
        {
          h81 = mkDeployConfig "h81.casa.lan" self.nixosConfigurations.h81;
          rpi3 = mkDeployConfig "rpi3.casa.lan" self.nixosConfigurations.rpi3;
          cp6230 = mkDeployConfig "cp6230.casa.lan" self.nixosConfigurations.cp6230;
          l50 = mkDeployConfig "l50.casa.lan" self.nixosConfigurations.l50;
          oracle1 = mkDeployConfig "${builtins.readFile (secrets + "/plain/oracle1_ip")}" self.nixosConfigurations.oracle1;
          oracle2 = mkDeployConfig "${builtins.readFile (secrets + "/plain/oracle2_ip")}" self.nixosConfigurations.oracle2;
        };
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
