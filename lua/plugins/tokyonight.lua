return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
			light_style = "day",
			on_colors = function(colors) end,
			on_highlights = function(hl, colors)
				hl.CursorLineNr = { fg = "#ff9e64" }
				hl.LineNr = { fg = "#7aa2f7" }
				hl.LineNrAbove = { fg = "#7f7f7f" }
				hl.LineNrBelow = { fg = "#666666" }
				hl.Visual = { bg = "#296015" }
				hl.Comment = { fg = "#75985d" }
			end,
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.opt.termguicolors = true
			vim.cmd("colorscheme tokyonight")
		end,
	},

	{
		"f-person/auto-dark-mode.nvim",
		lazy = false,
		priority = 1001,
		config = function()
			require("auto-dark-mode").setup({
				update_interval = 1000,
				set_dark_mode = function()
					vim.api.nvim_set_option_value("background", "dark", {})
					vim.cmd("colorscheme tokyonight")
				end,
				set_light_mode = function()
					vim.api.nvim_set_option_value("background", "light", {})
					vim.cmd("colorscheme tokyonight")
				end,
			})
		end,
	},
}
