return {
	{
		"folke/which-key.nvim",
		optional = true,
		opts = {
			spec = {
				{ "<leader>a", group = "codecompanion", mode = { "n", "v" } },
				{ "<localleader>a", group = "codecompanion", mode = { "n", "v" } },
			},
		},
	},
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"j-hui/fidget.nvim",
			{
				"MeanderingProgrammer/render-markdown.nvim",
				ft = { "markdown", "codecompanion" },
			},
		},

		cmd = {
			"CodeCompanion",
			"CodeCompanionChat",
			"CodeCompanionActions",
			"CodeCompanionAdd",
			"CodeCompanionLoad",
		},

		keys = {
			{
				"<leader>aa",
				":CodeCompanionActions<cr>",
				mode = { "n", "v" },
				desc = "Code Companion Actions",
			},
			{ "<leader>ac", ":CodeCompanionChat<cr>", mode = { "n", "v" }, desc = "Code Companion Chat" },
			{
				"<leader>ad",
				":CodeCompanion /doc<cr>",
				mode = { "v" },
				desc = "Code Companion Documentation",
			},
			{ "<leader>ae", ":CodeCompanionChat Add<cr>", mode = { "v" }, desc = "Code Companion Add" },
			{ "<leader>af", ":CodeCompanion /fix<cr>", mode = { "v" }, desc = "Code Companion Fix" },
			{
				"<leader>ag",
				":CodeCompanion /scommit<cr>",
				mode = { "n", "v" },
				desc = "Code Companion Commit",
			},
			{ "<leader>ah", ":CodeCompanionLoad<CR>", desc = "Codecompanion Load chat" },
			{
				"<leader>ai",
				":CodeCompanion /agent<cr>",
				mode = { "n", "v" },
				desc = "Code Companion Inline Prompt",
			},
			{ "<leader>al", ":CodeCompanion /lsp<cr>", mode = { "n", "v" }, desc = "Code Companion LSP" },
			{
				"<leader>an",
				function()
					require("codecompanion").chat()
				end,
				mode = { "n" },
				desc = "Code Companion New Chat",
			},
			{
				"<leader>ao",
				":CodeCompanion /optimize<cr>",
				mode = { "v" },
				desc = "Code Companion Refactor",
			},
			{ "<leader>ap", ":CodeCompanion /pr<cr>", mode = { "n" }, desc = "Code Companion PR" },
			{
				"<leader>as",
				":CodeCompanion /spell<cr>",
				mode = { "n", "v" },
				desc = "Code Companion Spell",
			},

			{ "<leader>at", ":CodeCompanionChat Toggle<CR>", desc = "Codecompanion toggle" },
			{
				"<C-a>",
				"<cmd>CodeCompanionActions<CR>",
				desc = "Open the action palette",
				mode = { "n", "v" },
			},
		},

		init = function()
			vim.cmd([[cab cc CodeCompanion]])
			require("plugins.codecompanion.utils.spinner"):init()
		end,

		opts = {
			opts = {
				-- Set debug logging
				show_defaults = true,
				log_level = "DEBUG",
			},
			strategies = {
				chat = {
					opts = {
						goto_file_action = "edit",
						system_prompt = function()
							return "You are a world class programming AI assistant. Help the user with their coding tasks."
						end,
					},
					roles = {
						user = "",
						llm = function(adapter)
							return "  " .. adapter.formatted_name
						end,
					},
					keymaps = {
						clear = { modes = { n = "<C-x>" } },
						next_chat = { modes = { n = "<A-l>" } },
						previous_chat = { modes = { n = "<A-h>" } },
						regenerate = { modes = { n = "<localleader>r" } },
						stop = { modes = { n = "q" } },
						codeblock = { modes = { n = "<localleader>c" } },
						yank_code = { modes = { n = "<localleader>y" } },
						pin = { modes = { n = "<localleader>p" } },
						watch = { modes = { n = "<localleader>w" } },
						change_adapter = { modes = { n = "<localleader>a" } },
						fold_code = { modes = { n = "<localleader>f" } },
						debug = { modes = { n = "<localleader>d" } },
						system_prompt = { modes = { n = "<localleader>s" } },
					},
				},
			},
			display = {
				chat = {
					show_settings = false,
				},
				action_palette = {
					provider = "default", -- default|telescope|mini_pick
				},
				diff = {
					enabled = true,
				},
			},
		},

		config = function(_, opts)
			require("codecompanion").setup(opts)
		end,
	},
}
