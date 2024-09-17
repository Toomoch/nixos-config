{ lib, pkgs, config, ... }:
let
  shellaliases = {
    vim = "nvim";
  };
  vim-minizinc = pkgs.vimUtils.buildVimPlugin {
    name = "vim-minizinc";
    src = pkgs.fetchFromGitHub {
      owner = "vale1410";
      repo = "vim-minizinc";
      rev = "83ac0d6b8ceab3417b43925a99894c0423e3c492";
      hash = "sha256-PLMeTZVn/17yC77qH7EiXguYUtENclrV+gWB95Kbsz0=";
    };
  };
in
{
  home.packages = with pkgs; [ ripgrep bitbake-language-server ];
  # :autocmd BufNewFile,BufRead sw-description set ft=cfg

  #programs.bash.shellAliases = shellaliases;
  #programs.zsh.shellAliases = shellaliases;

  programs.nixvim = {
    defaultEditor = true;
    #vimdiffAlias = true;
    extraPlugins = with pkgs; [
      vimPlugins.vim-just
      vimPlugins.vim-shellcheck
      vimPlugins.markdown-preview-nvim
      vimPlugins.vim-caddyfile
      vimPlugins.vim-markdown-toc
      vim-minizinc
    ];
    enable = true;
    clipboard.providers.wl-copy.enable = true;
    vimAlias = true;
    keymaps = [
      {
        action = "<cmd>NvimTreeToggle<cr>";
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
        action = ''"+y'';
        key = "<leader>y";
      }
      {
        action = "<Nop>";
        key = "<Down>";
      }
      {
        action = "<Nop>";
        key = "<Left>";
      }
      {
        action = "<Nop>";
        key = "<Right>";
      }
      {
        action = "<Nop>";
        key = "<Up>";
      }
    ];

    colorschemes.gruvbox.enable = true;
    opts = {
      smartindent = true;
      expandtab = true;
      #clipboard = "unnamedplus";
      number = true;
      wrap = true;
    };
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    extraConfigLuaPost = ''
      vim.api.nvim_create_autocmd({ "BufEnter" }, {
        pattern = { "*.bb", "*.bbappend", "*.bbclass", "*.inc", "conf/*.conf" },
        callback = function()
          vim.lsp.start({
            name = "bitbake",
            cmd = { "bitbake-language-server" }
          })
        end,
      })
    '';

    plugins = {
      nix.enable = true;
      treesitter.enable = true;
      auto-save.enable = true;
      luasnip.enable = true;
      fugitive.enable = true;
      nvim-tree.enable = true;
      telescope.enable = true;
      cmp_luasnip.enable = true;
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "path"; }
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "buffer"; }
        ];
        settings.snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        settings.mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
      };

      cmp-nvim-lsp.enable = true;
      lualine.enable = true;

      lsp = {
        enable = true;
        keymaps = {
          lspBuf = {
            "<space>lf" = "format";
            K = "hover";
            gD = "references";
            gd = "definition";
            gi = "implementation";
            gt = "type_definition";
            "<leader>ca" = {
              action = "code_action";
            };
          };
          diagnostic = {
            "<leader>j" = "goto_next";
            "<leader>k" = "goto_prev";
          };
        };
        servers = {
          nixd = {
            enable = true;
          };
          ltex = {
            enable = true;
            settings.language = "ca-ES";
          };
          texlab.enable = true;
          dockerls.enable = true;
          clangd.enable = true;
          ruff-lsp.enable = true;
          jsonls.enable = true;
          bashls.enable = true;
          ansiblels.enable = true;
        };
      };
    };
  };

}
