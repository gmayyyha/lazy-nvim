return {
	"akinsho/bufferline.nvim",
	depenndencies = {
		"nvim-tree/nvim-web-devicons",
		{ "echasnovski/mini.nvim", version = false },
	},
	version = "*",

	config = function()
		local bufferline = require("bufferline")
		bufferline.setup({
			options = {
				separator_style = "slant",
				close_command = "bdelete! %d", -- can be a string | function, | false see "Mouse actions"
				buffer_close_icon = "󰅖",
				modified_icon = "●",
				close_icon = "",
				left_trunc_marker = "",
				right_trunc_marker = "",
				diagnostics = "nvim_lsp",
			},
		})

		local keymap = vim.keymap

		keymap.set("n", "<C-l>", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
		keymap.set("n", "<C-h>", "<cmd>bprevious<CR>", { desc = "Go to previous buffer" })
		keymap.set("n", "<C-x>", "<cmd>bd<CR>", { desc = "Close current buffer" })
		keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
		keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
		keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
		keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
		keymap.set("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })
	end,
}
