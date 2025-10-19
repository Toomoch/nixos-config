{
  description = "Arnau NixOS configs";

  inputs = {
    self.submodules = true;

    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixpkgs-stable.url = "https://channels.nixos.org/nixos-25.05/nixexprs.tar.xz";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
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
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
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
      nixCats,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # specialArgs
      secrets = import /${private}/secrets/secrets.nix;
      flake-root = ./.;
      private = /${flake-root}/private;
      inherit (inputs.nixCats) utils;

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
          arch = "x86_64-linux";
          branch = stable;
          hm = false;
        }
        {
          host = "ps42";
          arch = "x86_64-linux";
          branch = stable;
          hm = true;
        }
        {
          host = "h81";
          arch = "x86_64-linux";
          branch = stable;
          hm = true;
        }
        {
          host = "b450";
          arch = "x86_64-linux";
          branch = stable;
          hm = true;
        }
        {
          host = "rpi3";
          arch = "aarch64-linux";
          branch = stable;
          hm = false;
        }
        {
          host = "oracle2";
          arch = "aarch64-linux";
          branch = stable;
          hm = false;
        }
        {
          host = "x550";
          arch = "x86_64-linux";
          branch = stable;
          hm = false;
        }
        {
          host = secrets.work.hostName;
          arch = "x86_64-linux";
          branch = stable;
          hm = true;
        }
        {
          host = "vm";
          arch = "x86_64-linux";
          branch = stable;
          hm = true;
        }
      ];

      forAllSystems =
        let
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
        in
        function: pkgs:
        nixpkgs.lib.genAttrs systems (
          system:
          let
            syspkgs = import pkgs {
              inherit system;
              config.allowUnfree = true;
            };
          in
          function syspkgs system
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

      luaPath = ./neovim;
      categoryDefinitions =
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }@packageDef:
        {
          # to define and use a new category, simply add a new list to a set here,
          # and later, you will include categoryname = true; in the set you
          # provide when you build the package using this builder function.
          # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

          # lspsAndRuntimeDeps:
          # this section is for dependencies that should be available
          # at RUN TIME for plugins. Will be available to PATH within neovim terminal
          # this includes LSPs
          lspsAndRuntimeDeps = {
            # some categories of stuff.
            general = with pkgs; [
              universal-ctags
              ripgrep
              fd
            ];
            # these names are arbitrary.
            lint = with pkgs; [
            ];
            # but you can choose which ones you want
            # per nvim package you export
            debug = with pkgs; {
              go = [ delve ];
            };
            go = with pkgs; [
              gopls
              gotools
              go-tools
              gccgo
            ];
            # and easily check if they are included in lua
            format = with pkgs; [
            ];
            neonixdev = {
              # also you can do this.
              inherit (pkgs) nix-doc lua-language-server nixd;
              # and each will be its own sub category
            };
          };

          # This is for plugins that will load at startup without using packadd:
          startupPlugins = {
            debug = with pkgs.vimPlugins; [
              nvim-nio
            ];
            general = with pkgs.vimPlugins; {
              # you can make subcategories!!!
              # (always isnt a special name, just the one I chose for this subcategory)
              always = [
                lze
                lzextras
                vim-repeat
                plenary-nvim
                (nvim-notify.overrideAttrs { doCheck = false; }) # TODO: remove overrideAttrs after check is fixed
              ];
              extra = [
                oil-nvim
                nvim-web-devicons
              ];
            };
            # You can retreive information from the
            # packageDefinitions of the package this was packaged with.
            # :help nixCats.flake.outputs.categoryDefinitions.scheme
            themer =
              with pkgs.vimPlugins;
              (builtins.getAttr (categories.colorscheme or "onedark") {
                # Theme switcher without creating a new category
                "onedark" = onedark-nvim;
                "catppuccin" = catppuccin-nvim;
                "catppuccin-mocha" = catppuccin-nvim;
                "tokyonight" = tokyonight-nvim;
                "tokyonight-day" = tokyonight-nvim;
              });
            # This is obviously a fairly basic usecase for this, but still nice.
          };

          # not loaded automatically at startup.
          # use with packadd and an autocommand in config to achieve lazy loading
          # or a tool for organizing this like lze or lz.n!
          # to get the name packadd expects, use the
          # `:NixCats pawsible` command to see them all
          optionalPlugins = {
            debug = with pkgs.vimPlugins; {
              # it is possible to add default values.
              # there is nothing special about the word "default"
              # but we have turned this subcategory into a default value
              # via the extraCats section at the bottom of categoryDefinitions.
              default = [
                nvim-dap
                nvim-dap-ui
                nvim-dap-virtual-text
              ];
              go = [ nvim-dap-go ];
            };
            lint = with pkgs.vimPlugins; [
              nvim-lint
            ];
            format = with pkgs.vimPlugins; [
              conform-nvim
            ];
            markdown = with pkgs.vimPlugins; [
              markdown-preview-nvim
            ];
            neonixdev = with pkgs.vimPlugins; [
              lazydev-nvim
            ];
            general = {
              blink = with pkgs.vimPlugins; [
                luasnip
                cmp-cmdline
                blink-cmp
                blink-compat
                colorful-menu-nvim
              ];
              treesitter = with pkgs.vimPlugins; [
                nvim-treesitter-textobjects
                nvim-treesitter.withAllGrammars
                # This is for if you only want some of the grammars
                # (nvim-treesitter.withPlugins (
                #   plugins: with plugins; [
                #     nix
                #     lua
                #   ]
                # ))
              ];
              telescope = with pkgs.vimPlugins; [
                telescope-fzf-native-nvim
                telescope-ui-select-nvim
                telescope-nvim
              ];
              always = with pkgs.vimPlugins; [
                nvim-lspconfig
                lualine-nvim
                gitsigns-nvim
                vim-sleuth
                vim-fugitive
                vim-rhubarb
                nvim-surround
              ];
              extra = with pkgs.vimPlugins; [
                fidget-nvim
                # lualine-lsp-progress
                which-key-nvim
                comment-nvim
                undotree
                indent-blankline-nvim
                vim-startuptime
                # If it was included in your flake inputs as plugins-hlargs,
                # this would be how to add that plugin in your config.
                # pkgs.neovimPlugins.hlargs
              ];
            };
          };
        };
      packageDefinitions = {
        # the name here is the name of the package
        # and also the default command name for it.
        nixCats =
          { pkgs, name, ... }@misc:
          {
            # these also recieve our pkgs variable
            # see :help nixCats.flake.outputs.packageDefinitions
            settings = {
              suffix-path = true;
              suffix-LD = true;
              # The name of the package, and the default launch name,
              # and the name of the .desktop file, is `nixCats`,
              # or, whatever you named the package definition in the packageDefinitions set.
              # WARNING: MAKE SURE THESE DONT CONFLICT WITH OTHER INSTALLED PACKAGES ON YOUR PATH
              # That would result in a failed build, as nixos and home manager modules validate for collisions on your path
              aliases = [
                "vim"
                "vimcat"
              ];

              # explained below in the `regularCats` package's definition
              # OR see :help nixCats.flake.outputs.settings for all of the settings available
              wrapRc = true;
              configDirName = "nixCats-nvim";
              hosts.python3.enable = true;
              hosts.node.enable = true;
            };
            # enable the categories you want from categoryDefinitions
            categories = {
              markdown = true;
              general = true;
              lint = true;
              format = true;
              neonixdev = true;
              test = {
                subtest1 = true;
              };

              # enabling this category will enable the go category,
              # and ALSO debug.go and debug.default due to our extraCats in categoryDefinitions.
              # go = true; # <- disabled but you could enable it with override or module on install

              # this does not have an associated category of plugins,
              # but lua can still check for it
              lspDebugMode = false;
              # you could also pass something else:
              # see :help nixCats
              themer = true;
              colorscheme = "onedark";
            };
            extra = {
              # to keep the categories table from being filled with non category things that you want to pass
              # there is also an extra table you can use to pass extra stuff.
              # but you can pass all the same stuff in any of these sets and access it in lua
              nixdExtras = {
                nixpkgs = ''import ${pkgs.path} {}'';
                # or inherit nixpkgs;
              };
            };
          };

        regularCats =
          { pkgs, ... }@misc:
          {
            settings = {
              suffix-path = true;
              suffix-LD = true;
              # IMPURE PACKAGE: normal config reload
              # include same categories as main config,
              # will load from vim.fn.stdpath('config')
              wrapRc = false;
              # or tell it some other place to load
              # unwrappedCfgPath = "/some/path/to/your/config";

              # configDirName: will now look for nixCats-nvim within .config and .local and others
              # this can be changed so that you can choose which ones share data folders for auths
              # :h $NVIM_APPNAME
              configDirName = "nixCats-nvim";

              aliases = [ "testCat" ];

            };
            categories = {
              markdown = true;
              general = true;
              neonixdev = true;
              lint = true;
              format = true;
              test = true;
              # go = true; # <- disabled but you could enable it with override or module on install
              lspDebugMode = false;
              themer = true;
              colorscheme = "catppuccin";
            };
          };
      };

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
        oracle2 = {
          targetHost = "oracle2";
          buildOnTarget = true;
          targetUser = "arnau";
        };
        oracle1 = {
          targetHost = "oracle1";
          targetUser = "arnau";
        };
      };
      # Import every package found in the attr pkgs from ./pkgs/default.nix
      # packages = forAllSystems (pkgs: system: import ./pkgs pkgs nixvim system utils) nixpkgs-stable;
      packages = forAllSystems (pkgs: system:
        let
          # 1. Build your existing packages
          existingPackages = import ./pkgs pkgs nixvim system;

          # 2. Build the nixCats packages
          nixCatsBuilder = utils.baseBuilder luaPath {
            inherit nixpkgs system;
            dependencyOverlays = [ (utils.standardPluginOverlay inputs) ];
          } categoryDefinitions packageDefinitions;

          nixCatsPackages = utils.mkAllWithDefault (nixCatsBuilder "nixCats");
        in
        # 3. Merge both sets of packages
         existingPackages // nixCatsPackages
      ) nixpkgs-stable;
      nixosModules.common = import ./modules/nixos;
      nixosModules.private = import /${private}/modules/nixos;
      homeManagerModules.common = import ./modules/home-manager;
      overlays = import ./overlays { inherit inputs nixvim; };

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
              arch,
              branch,
              hm,
              ...
            }:
            {
              name = host;
              value =
                let # surely theres a better way of doing this
                  host-folder = secrets.hosts.${host}.hostFolder;
                  specialArgs = {
                    inherit
                      inputs
                      secrets
                      flake-root
                      private
                      agenix-rekey
                      self
                      outputs
                      ;
                    nixpkgs = branch.nixpkgs;
                    nixpkgs-unstable = nixpkgs;
                  };
                in
                branch.nixpkgs.lib.nixosSystem {
                  system = arch;
                  inherit specialArgs;
                  modules =
                    defaultModules host-folder branch
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
                            users.${user}.imports = [ self.homeManagerModules.common ];
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
          oracle2 = mkDeployConfig "oracle2" self.nixosConfigurations.oracle2 false true;
        };
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
