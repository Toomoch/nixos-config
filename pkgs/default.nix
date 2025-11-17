{
  pkgs,
  nixvim,
  mnw,
}:
rec {
  huawei_solar = pkgs.callPackage ./huawei_solar.nix { inherit huawei-solar; };
  huawei-solar = pkgs.callPackage ./huawei-solar.nix {
    inherit (pkgs.home-assistant.python.pkgs)
      backoff
      hatchling
      hatch-vcs
      pytz
      pymodbus
      pyserial-asyncio
      typing-extensions
      pytest-asyncio
      pytestCheckHook
      buildPythonPackage
      ;
  };
  som-energia-hass = pkgs.callPackage ./som-energia-hass.nix { };
  nvim = nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
    module = ../nixvim;
  };
  help-blog = pkgs.callPackage ./blog.nix { };
  notion_todo = pkgs.callPackage ./notion_todo.nix { };
  nvim-mnw = mnw.lib.wrap pkgs {
    appName = "nvim-mnw";
    neovim = pkgs.neovim-unwrapped;
    initLua = ''
      require('myconfig')
    '';
    extraBinPath = [
      pkgs.clang
      pkgs.gitlab-ci-ls
      pkgs.lua-language-server
      pkgs.bash-language-server
      pkgs.yaml-language-server
      pkgs.ruff
      pkgs.ty
      pkgs.rust-analyzer
      pkgs.tombi
      pkgs.vscode-langservers-extracted
    ];
    plugins = {
      start = with pkgs.vimPlugins; [
        oil-nvim
        fzf-lua
        vim-tmux-navigator
        luasnip
        nvim-treesitter.withAllGrammars
        vim-fugitive
        kanagawa-nvim
        nvim-web-devicons
        nvim-cmp
        cmp-buffer
        cmp-path
        cmp-nvim-lsp
        lualine-nvim
      ];
      dev.myconfig = {
        pure = ../neovim;
        impure = "/home/arnau/projects/nixos-config/neovim";
      };

    };
  };

}
