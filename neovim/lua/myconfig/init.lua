do
	local nixvim_options = { expandtab = true, number = true, smartindent = true, wrap = true }

	for k, v in pairs(nixvim_options) do
		vim.opt[k] = v
	end
end

do
	local nixvim_globals = { mapleader = " ", maplocalleader = " " }

	for k, v in pairs(nixvim_globals) do
		vim.g[k] = v
	end
end

require("kanagawa").setup({ background = { dark = "dragon" } })

vim.diagnostic.config({ virtual_text = true })

vim.cmd([[colorscheme kanagawa
]])

-- require("luasnip").config.setup({})
--
-- require("lualine").setup({})
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
})

require("fzf-lua").setup({})

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
		{ action = '"_dP', key = "<leader>p", mode = "" },
		{ action = '"_d', key = "<leader>d", mode = "" },
		{ action = '"+y', key = "<leader>y", mode = "" },
		{ action = "<Nop>", key = "<Down>", mode = "" },
		{ action = "<Nop>", key = "<Left>", mode = "" },
		{ action = "<Nop>", key = "<Right>", mode = "" },
		{ action = "<Nop>", key = "<Up>", mode = "" },
		{ action = ":Ge:<CR>", key = "<leader>gs", mode = "", options = { desc = "Git status" } },
		{
			action = ":set nosplitright<CR>:execute 'Gvdiff ' .. g:git_base<CR>:set splitright<CR>",
			key = "<leader>gd",
			mode = "",
			options = { desc = "Git diff" },
		},
		{ action = ":Git blame<CR>", key = "<leader>gb", mode = "", options = { desc = "Git blame" } },
		{ action = ":0Gclog<CR>", key = "<leader>gc", mode = "", options = { desc = "Git log-pick" } },
		{ action = ":Git push<CR>", key = "<leader>gp", mode = "", options = { desc = "Git push" } },
		{ action = ":Git pull<CR>", key = "<leader>gP", mode = "", options = { desc = "Git pull" } },
		{ action = ":TmuxNavigateLeft<CR>", key = "<M-h>", mode = "" },
		{ action = ":TmuxNavigateDown<CR>", key = "<M-j>", mode = "" },
		{ action = ":TmuxNavigateUp<CR>", key = "<M-k>", mode = "" },
		{ action = ":TmuxNavigateRight<CR>", key = "<M-l>", mode = "" },
		{ action = ":TmuxNavigatePrevious<CR>", key = "<M-\\>", mode = "" },
		{ action = "<C-d>zz", key = "<C-d>", mode = "" },
		{ action = "<C-u>zz", key = "<C-u>", mode = "" },
		{ action = ":Explore<cr>", key = "-", mode = "" },
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

local cache_dir = vim.uv.os_homedir() .. '/.cache/gitlab-ci-ls/'

vim.lsp.config.gitlab_ci_ls = {
  cmd = { 'gitlab-ci-ls' },
  filetypes = { 'yaml.gitlab' },
  root_markers = { '.git', '.gitlab-ci.yml' },
  init_options = {
    cache_path = cache_dir,
    log_path = cache_dir .. '/log/gitlab-ci-ls.log',
  },
}

vim.lsp.enable({'clangd'})
vim.lsp.enable({'gitlab_ci_ls'})

