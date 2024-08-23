return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			on_highlights = function(hl)
				-- https://github.com/folke/tokyonight.nvim/blob/main/extras/lua/tokyonight_night.lua
				hl.CursorLineNr = { fg = "#ff9e64" }
				hl.LineNr = { fg = "#7aa2f7" }
				hl.LineNrAbove = { fg = "#7f7f7f" }
				hl.LineNrBelow = { fg = "#666666" }
				hl.Visual = { bg = "#296015" }
				--                hl.Comment = { fg = "#e5e5e5" }
				hl.Comment = { fg = "#75985d" }
			end,
		})

		vim.cmd("colorscheme tokyonight-night")
	end,
}
