{
  description = "Arnau NixOS configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-stable.url = "nixpkgs/nixos-24.05";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    #hyprland.url = "github:hyprwm/Hyprland";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko-stable = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-matlab.url = "gitlab:doronbehar/nix-matlab";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    #ags.url = "github:Aylur/ags";
    #matugen.url = "github:InioX/matugen";

    private.url = "git+ssh://git@github.com/Toomoch/nixos-config-private.git";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixpkgs-stable, home-manager-stable, sops-nix, deploy-rs, nix-matlab, private, nixvim, disko-stable, disko, nix-on-droid, ... }:
    let
      secrets = "${private}/secrets/";
      workhostname = "${builtins.readFile (secrets + "plain/hostname")}";
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
        ]
          (system: function nixpkgs.legacyPackages.${system});

      hostip = host: "${builtins.readFile (secrets + "plain/" + host + "_ip")}";
      stable = { nixpkgs = nixpkgs-stable; home-manager = home-manager-stable; disko = disko-stable; };
      unstable = { nixpkgs = nixpkgs; home-manager = home-manager; disko = disko; };

      hosts = [
        { host = "oracle1"; arch = "x86_64-linux"; branch = stable; hm = false; }
        { host = "ps42"; arch = "x86_64-linux"; branch = stable; hm = true; }
        { host = "h81"; arch = "x86_64-linux"; branch = stable; hm = true; }
        { host = "b450"; arch = "x86_64-linux"; branch = unstable; hm = true; }
        { host = "rpi3"; arch = "aarch64-linux"; branch = stable; hm = false; }
        { host = "oracle2"; arch = "aarch64-linux"; branch = unstable; hm = false; }
        { host = workhostname; arch = "x86_64-linux"; branch = stable; hm = true; }
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
          { inherit inputs; inherit nixpkgs; };
        modules = [
          ./nix-on-droid
          {
            home-manager = {
              config.imports = [ sops-nix.homeManagerModules.sops ];
              extraSpecialArgs = { inherit inputs; };
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
          ];
        };
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

          specialArgs = { inherit inputs; };
          extraSpecialArgs = { inherit inputs; };

          mkHostConfig = { host, arch, branch, hm, ... }: {
            name = host;
            value =
              let # surely theres a better way of doing this
                host-folder =
                  if host == workhostname then
                    "work"
                  else
                    host;
                pkgs-unstable = import nixpkgs { system = arch; };
              in
              branch.nixpkgs.lib.nixosSystem {
                system = arch;
                specialArgs =
                  let
                    nixpkgs = branch.nixpkgs;
                  in
                  { inherit pkgs-unstable; inherit inputs; inherit nixpkgs; };
                modules = defaultModules host-folder branch.disko ++ branch.nixpkgs.lib.optional (branch == stable) ./system/modules/stable-overlays.nix
                  ++ branch.nixpkgs.lib.optionals hm [
                  branch.home-manager.nixosModules.home-manager
                  {
                    home-manager = 
                      let
                        user = 
                          if host == workhostname then
                            "avalls"
                          else
                            "arnau";
                    {
                      useGlobalPkgs = true;
                      extraSpecialArgs = { inherit pkgs-unstable; inherit inputs; };
                      users.${user}.imports = [
                        ./home/machine/${host-folder}.nix
                        sops-nix.homeManagerModules.sops
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
          rpi3 = mkDeployConfig "rpi3.casa.lan" self.nixosConfigurations.rpi3 true false;
          l50 = mkDeployConfig "l50.casa.lan" self.nixosConfigurations.l50 true false;
          oracle1 = mkDeployConfig "oracle1" self.nixosConfigurations.oracle1 false false;
          oracle2 = mkDeployConfig "oracle2" self.nixosConfigurations.oracle2 false true;
        };
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
