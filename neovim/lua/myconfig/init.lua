-- opts
do
  local opts = {
    expandtab = true,
    number = true,
    smartindent = true,
    wrap = true,
  }
  for k, v in pairs(opts) do
    vim.opt[k] = v
  end
end

do
  local globals = {
    mapleader = " ",
    maplocalleader = " ",
  }
  for k, v in pairs(globals) do
    vim.g[k] = v
  end
end

-- Theme
require("kanagawa").setup({ background = { dark = "wave" } })
vim.cmd.colorscheme("kanagawa")

-- Plugins
require("lualine").setup({})
require("oil").setup()
require("fzf-lua").setup({})
require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
})
require('render-markdown').setup({
  enabled = true,
  heading = {
    enabled = false,
  },
  code = {
    highlight = "RenderMarkdownCode",
    highlight_inline = "RenderMarkdownCodeInline",
    style = "full",
  }
})
vim.diagnostic.config({ virtual_text = true })

-- Set up keybinds {{{
do
  local __nixvim_binds = {
    {
      action = function()
        require("fzf-lua").grep_curbuf()
      end,
      key = "<leader>fd",
      mode = "n",
    },
    {
      action = function()
        require("fzf-lua").files()
      end,
      key = "<leader>ff",
      mode = "n",
    },
    {
      action = function()
        require("fzf-lua").grep_project()
      end,
      key = "<leader>fg",
      mode = "n",
    },
    { action = '"_dP',     key = "<leader>p",  mode = "" },
    { action = '"_d',      key = "<leader>d",  mode = "" },
    { action = '"+y',      key = "<leader>y",  mode = "" },
    { action = "<Nop>",    key = "<Down>",     mode = "" },
    { action = "<Nop>",    key = "<Left>",     mode = "" },
    { action = "<Nop>",    key = "<Right>",    mode = "" },
    { action = "<Nop>",    key = "<Up>",       mode = "" },
    { action = ":Ge:<CR>", key = "<leader>gs", mode = "", options = { desc = "Git status" } },
    {
      action = ":set nosplitright<CR>:execute 'Gvdiff ' .. g:git_base<CR>:set splitright<CR>",
      key = "<leader>gd",
      mode = "",
      options = { desc = "Git diff" },
    },
    { action = ":Git blame<CR>",            key = "<leader>gb", mode = "", options = { desc = "Git blame" } },
    { action = ":0Gclog<CR>",               key = "<leader>gc", mode = "", options = { desc = "Git log-pick" } },
    { action = ":Git push<CR>",             key = "<leader>gp", mode = "", options = { desc = "Git push" } },
    { action = ":Git pull<CR>",             key = "<leader>gP", mode = "", options = { desc = "Git pull" } },
    { action = ":TmuxNavigateLeft<CR>",     key = "<M-h>",      mode = "" },
    { action = ":TmuxNavigateDown<CR>",     key = "<M-j>",      mode = "" },
    { action = ":TmuxNavigateUp<CR>",       key = "<M-k>",      mode = "" },
    { action = ":TmuxNavigateRight<CR>",    key = "<M-l>",      mode = "" },
    { action = ":TmuxNavigatePrevious<CR>", key = "<M-\\>",     mode = "" },
    { action = "<C-d>zz",                   key = "<C-d>",      mode = "" },
    { action = "<C-u>zz",                   key = "<C-u>",      mode = "" },
    { action = ":Oil<cr>",                  key = "-",          mode = "" },
  }
  for i, map in ipairs(__nixvim_binds) do
    vim.keymap.set(map.mode, map.key, map.action, map.options)
  end
end
-- }}}

vim.filetype.add({
  extension = {
    automount = "systemd",
    caddyfile = "caddy",
    j2 = "jinja",
    jinja = "jinja",
    jinja2 = "jinja",
    mount = "systemd",
    path = "systemd",
    scope = "systemd",
    service = "systemd",
    slice = "systemd",
    socket = "systemd",
    swap = "systemd",
    target = "systemd",
    timer = "systemd",
  },
  filename = { Caddyfile = "caddy" },
  pattern = {
    [".*%.gitlab%-ci%.yml"] = "yaml.gitlab",
    [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*%.ya?ml"] = "yaml.ansible",
    [".*/tasks/.*%.ya?ml"] = "yaml.ansible",
    [".*/templates?/.*%.tmpl"] = "gotmpl",
    [".*playbook.*%.ya?ml"] = "yaml.ansible",
  },
})

vim.lsp.config.clangd = {
  cmd = { 'clangd', '--background-index' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt' },
  filetypes = { 'c', 'cpp' },
}

local cache_dir = vim.uv.os_homedir() .. '/.cache/gitlab-ci-ls'

vim.lsp.config.gitlab_ci_ls = {
  cmd = { 'gitlab-ci-ls' },
  filetypes = { 'yaml.gitlab' },
  root_markers = { '.git', '.gitlab-ci.yml' },
  init_options = {
    cache_path = cache_dir,
    log_path = cache_dir .. '/log/gitlab-ci-ls.log',
  },
}

vim.lsp.enable({ 'clangd' })
vim.lsp.enable({ 'gitlab_ci_ls' })

vim.lsp.config.bashls = {
  cmd = { 'bash-language-server', 'start' },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
    },
  },
  filetypes = { 'bash', 'sh' },
  root_markers = { '.git' },
}
vim.lsp.enable({ 'bashls' })

vim.lsp.config.lua_ls = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
    '.git',
  },
  settings = {
    Lua = {
      diagnostics = {
        globals = {
          'vim'
        }
      }
    }
  }

}

vim.lsp.enable({ 'lua_ls' })

vim.lsp.config.yamlls = {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab', 'yaml.helm-values' },
  root_markers = { '.git' },
  settings = {
    -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
    redhat = { telemetry = { enabled = false } },
    -- formatting disabled by default in yaml-language-server; enable it
    yaml = {
      format = { enable = true },
      customTags = {
        '!unsafe scalar',
      },
    },
  },
  on_init = function(client)
    --- https://github.com/neovim/nvim-lspconfig/pull/4016
    --- Since formatting is disabled by default if you check `client:supports_method('textDocument/formatting')`
    --- during `LspAttach` it will return `false`. This hack sets the capability to `true` to facilitate
    --- autocmd's which check this capability
    client.server_capabilities.documentFormattingProvider = true
  end,
}

vim.lsp.enable({ 'yamlls' })

vim.lsp.config.nixd = {
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
}

vim.lsp.enable({ 'nixd' })

vim.lsp.config.ty = {
  cmd = { 'ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'ty.toml', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
}
vim.lsp.enable({ 'ty' })
vim.lsp.config.ruff = {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  settings = {},
}

vim.lsp.enable('ruff')


vim.lsp.config.rust_analyzer = {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { '.git', 'Cargo.lock' },
  capabilities = {
    experimental = {
      serverStatusNotification = true,
    },
  },
}
vim.lsp.enable({ 'rust_analyzer' })

vim.lsp.config.tombi = {
  cmd = { 'tombi', 'lsp' },
  filetypes = { 'toml' },
  root_markers = { '.git', 'tombi.toml', 'pyproject.toml' },
}

vim.lsp.enable({ 'tombi' })

vim.lsp.config.jsonls = {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  init_options = {
    provideFormatter = true,
  },
  root_markers = { '.git' },
}

vim.lsp.enable({ 'jsonls' })

vim.lsp.config.jinja = {
  cmd = { 'jinja-lsp' },
  filetypes = { 'jinja' },
  root_markers = { '.git' },
}
vim.lsp.enable({ 'jinja' })


local cmp = require("cmp")
cmp.setup({
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
    ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  sources = { { name = "path" }, { name = "nvim_lsp" }, { name = "buffer" } },
})


local on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('gd', vim.lsp.buf.definition, 'Go to Definition')
  nmap('gi', vim.lsp.buf.implementation, 'Go to Implementation')
  nmap('gD', vim.lsp.buf.references, 'Go to References')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Actions')
  nmap('<leader>lf', vim.lsp.buf.format, 'Format Buffer')
  nmap('<leader>k', vim.diagnostic.goto_prev, 'Previous Diagnostic')
  nmap('<leader>j', vim.diagnostic.goto_next, 'Next Diagnostic')
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf
    on_attach(client, bufnr)
  end,
})
