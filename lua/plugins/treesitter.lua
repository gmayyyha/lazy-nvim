return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",

	dependencies = {
		"windwp/nvim-ts-autotag",
	},

	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		---@diagnostic disable-next-line: missing-fields
		treesitter.setup({
			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = true,

			ignore_install = {},

			highlight = {
				enable = true,
			},
			-- enable indentation
			indent = {
				enable = true,
			},
			autotag = {
				enable = true,
			},
			-- ensure these language parsers are installed
			ensure_installed = {
				"c",
				"cpp",
				"java",
				"javascript",
				"typescript",
				"python",
				"go",
				"rust",
				"css",
				"html",
				"yaml",
				"json",
				"xml",
				"vim",
				"vimdoc",
				"bash",
				"markdown",
				"tsx",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
