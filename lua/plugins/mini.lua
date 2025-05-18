return {
	{ "echasnovski/mini.nvim", version = "*" },

	{
		"echasnovski/mini.ai",
		version = "*",
		config = function()
			require("mini.ai").setup()
		end,
	},

	{
		"echasnovski/mini.cursorword",
		version = false,
		config = function()
			require("mini.cursorword").setup({})
		end,
	},

	{
		"echasnovski/mini.pairs",
		version = "*",
		config = function()
			require("mini.pairs").setup()
		end,
	},

	-- {
	-- 	"echasnovski/mini.indentscope",
	-- 	version = "*",
	-- 	config = function()
	-- 		require("mini.indentscope").setup({
	-- 			--    symbol = "│",
	-- 			--    options = { try_as_border = true },
	-- 		})
	-- 	end,
	-- },
}
