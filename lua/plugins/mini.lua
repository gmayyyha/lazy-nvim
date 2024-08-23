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

	-- {
	--     "echasnovski/mini.notify",
	--     version = "*",
	--     config = function()
	--         require("mini.notify").setup()
	--     end,
	-- },
}
