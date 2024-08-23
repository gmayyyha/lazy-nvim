return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	opts = {
		-- your connfiguration comes here
		-- or leave it empty to use the default settings
		-- refer to the connfiguration section below
		{
			notify = false,
		},
	},
}
