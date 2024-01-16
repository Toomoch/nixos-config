{ lib, pkgs, config, ... }:
{
  home.packages = with pkgs; [ ripgrep ];
  programs.nixvim = {
    enable = true;
    clipboard.providers.wl-copy.enable = true;
    keymaps = [
      {
        action = "<cmd>CHADopen<cr>";
        key = "<leader>e";
      }
      {
        action = "<cmd>Telescope find_files<cr>";
        key = "<leader>d";
      }
      {
        action = "<cmd>Telescope live_grep<cr>";
        key = "<leader>f";
      }
      {
        action = "<cmd>wincmd l<cr>";
        key = "<leader><Right>";
      }
      {
        action = "<cmd>wincmd h<cr>";
        key = "<leader><Left>";
      }
    ];

    colorschemes.gruvbox.enable = true;
    options = {
      smartindent = true;
      expandtab = true;
      clipboard = "unnamedplus";
      number = true;
    };
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    plugins = {
      nix.enable = true;
      treesitter.enable = true;
      auto-save.enable = true;
      chadtree.enable = true;
      luasnip.enable = true;
      telescope.enable = true;
      cmp_luasnip.enable = true;
      nvim-cmp = {
        enable = true;
        autoEnableSources = true;
        sources = [
          { name = "path"; }
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "buffer"; }
        ];
        snippet.expand = "luasnip";
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = {
            action = "cmp.mapping.select_next_item()";
            modes = [ "i" "s" ];
          };
        };
      };

      cmp-nvim-lsp.enable = true;
      lualine.enable = true;

      lsp = {
        enable = true;
        servers = {
          nixd = {
            enable = true;
          };
          dockerls.enable = true;
          clangd = {
            enable = true;
          };
          ansiblels.enable = true;
        };
      };
    };
  };

}
