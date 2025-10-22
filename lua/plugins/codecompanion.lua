--- Anthropic config for CodeCompanion.
local anthropic_fn = function()
	local anthropic_config = {
		env = {
			api_key = function()
				return os.getenv("ANTHROPIC_KEY")
			end,
		},
	}
	return require("codecompanion.adapters").extend("anthropic", anthropic_config)
end

--- OpenAI config for CodeCompanion.
local openai_fn = function()
	local openai_config = {
		env = { api_key = "cmd:op read op://Personal/OpenAI/tokens/neovim --no-newline" },
	}
	return require("codecompanion.adapters").extend("openai", openai_config)
end

--- Gemini config for CodeCompanion.
local gemini_fn = function()
	local gemini_config = {
		env = {
			api_key = function()
				return os.getenv("GEMINI_API_KEY")
			end,
		},
		schema = {
			model = {
				default = "gemini-2.5-flash",
			},
		},
	}
	return require("codecompanion.adapters").extend("gemini", gemini_config)
end

--- Deepseek config for CodeCompanion
local deepseek_fn = function()
	return require("codecompanion.adapters").extend("openai_compatible", {
		name = "deepseek",
		env = {
			url = "https://api.deepseek.com",
			api_key = function()
				return os.getenv("DEEPSEEK_KEY")
			end,
		},
	})
end

--- Ollama config for CodeCompanion.
local ollama_fn = function()
	return require("codecompanion.adapters").extend("ollama", {
		schema = {
			model = {
				default = "llama3.1:8b",
				-- default = "codellama:7b",
			},
			num_ctx = {
				default = 16384,
			},
			num_predict = {
				default = -1,
			},
		},
	})
end

local supported_adapters = {
	http = {
		anthropic = anthropic_fn,
		openai = openai_fn,
		gemini = gemini_fn,
		deepseek = deepseek_fn,
		ollama = ollama_fn,
	},
	acp = {
		gemini_cli = function()
			return require("codecompanion.adapters").extend("gemini_cli", {
				defaults = {
					-- auth_method = "gemini-api-key", -- "oauth-personal" | "gemini-api-key" | "vertex-ai"
					auth_method = "oauth-personal",
					-- auth_method = "vertex-ai",
				},
			})
		end,
	},
}

return {
	"olimorris/codecompanion.nvim",
	opts = {},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"j-hui/fidget.nvim",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			ft = { "markdown", "codecompanion" },
		},

		"ravitemer/codecompanion-history.nvim",
	},
	config = function()
		local function load_system_prompt(prompt_name)
			-- https://codecompanion.olimorris.dev/configuration/system-prompt.html#configuring-the-system-prompt
			local config_dir = vim.fn.stdpath("config")
			local prompt_path = config_dir .. "/lua/plugins/custom/prompts/" .. prompt_name .. ".txt"
			local lines = vim.fn.readfile(prompt_path)
			return table.concat(lines, "\n")
		end

		require("codecompanion").setup({
			opts = {
				-- Set debug logging
				show_defaults = true,
				log_level = "DEBUG",
			},
			adapters = supported_adapters,
			strategies = {
				chat = {
					adapter = "gemini",

					slash_commands = {
						["buffer"] = {
							opts = {
								provider = "snacks", -- default|telescope|mini_pick|fzf_lua
							},
						},

						["file"] = {
							callback = "strategies.chat.slash_commands.file",
							description = "Select a file using fzf_lua",
							opts = {
								provider = "snacks", -- default|telescope|mini_pick|fzf_lua
								contains_code = true,
							},
						},

						["help"] = {
							opts = {
								provider = "snacks", -- telescope|mini_pick|fzf_lua
							},
						},

						["symbols"] = {
							opts = {
								provider = "snacks", -- default|telescope|mini_pick|fzf_lua
							},
						},
					},
				},
				inline = { adapter = "gemini" },
				agent = { adapter = "gemini" },
				cmd = { adapter = "gemini" },
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
			extensions = {
				history = {
					enabled = true,
					opts = {
						-- Keymap to open history from chat buffer (default: gh)
						keymap = "ah",
						-- Automatically generate titles for new chats
						auto_generate_title = true,
						---On exiting and entering neovim, loads the last chat on opening chat
						continue_last_chat = false,
						---When chat is cleared with `gx` delete the chat from history
						delete_on_clearing_chat = false,
						-- Picker interface ("telescope" or "snacks" or "default")
						picker = "snacks",
						---Enable detailed logging for history extension
						enable_logging = false,
						---Directory path to save the chats
						dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
						-- Save all chats by default
						auto_save = true,
						-- Keymap to save the current chat manually
						save_chat_keymap = "sc",
					},
				},
				vectorcode = {
					---@type VectorCode.CodeCompanion.ExtensionOpts
					opts = {
						tool_group = {
							-- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
							enabled = true,
							-- a list of extra tools that you want to include in `@vectorcode_toolbox`.
							-- if you use @vectorcode_vectorise, it'll be very handy to include
							-- `file_search` here.
							extras = {},
							collapse = false, -- whether the individual tools should be shown in the chat
						},
						tool_opts = {
							---@type VectorCode.CodeCompanion.LsToolOpts
							ls = {},
							---@type VectorCode.CodeCompanion.VectoriseToolOpts
							vectorise = {},
							---@type VectorCode.CodeCompanion.QueryToolOpts
							query = {
								max_num = { chunk = -1, document = -1 },
								default_num = { chunk = 50, document = 10 },
								include_stderr = false,
								use_lsp = false,
								no_duplicate = true,
								chunk_mode = false,
							},
						},
					},
				},
			},
			prompt_library = {
				-- https://github.com/olimorris/codecompanion.nvim/blob/main/doc/RECIPES.md
				["Edit current buffer"] = {
					strategy = "chat",
					description = "Edit the current buffer",
					prompts = {
						{
							role = "system",
							content = "You are an AI assistant with access to the user's current code buffer",
						},
						{
							role = "user",
							content = "Please make the following changes using #buffer with @insert_edit_into_file\n\n",
						},
					},
				},
				["Code review"] = {
					strategy = "chat",
					description = "Code review",
					opts = {
						index = 4,
						ignore_system_prompt = true,
					},
					prompts = {
						{
							role = "system",
							content = load_system_prompt("code_review"),
						},
						{
							role = "user",
							content = "Please review provided code. " .. "#{buffer} #{lsp}",
						},
					},
				},
			},
		})
	end,
	keys = function()
		return {
			{ "<leader>ac", ":CodeCompanionChat anthropic<CR>", desc = "Codecompanion: Claude" },
			{ "<leader>ao", ":CodeCompanionChat openai<CR>", desc = "Codecompanion: OpenAI" },
			{ "<leader>ag", ":CodeCompanionChat gemini<CR>", desc = "Codecompanion: Gemini" },
			{ "<leader>al", ":CodeCompanionChat ollama<CR>", desc = "Codecompanion: Ollama" },

			{ "<leader>at", ":CodeCompanionChat Toggle<CR>", desc = "Codecompanion toggle" },
			{ "<leader>aL", ":CodeCompanionLoad<CR>", desc = "Codecompanion Load chat" },
			{
				"<C-a>",
				"<cmd>CodeCompanionActions<CR>",
				desc = "Open the action palette",
				mode = { "n", "v" },
			},
			{
				"<LocalLeader>a",
				"<cmd>CodeCompanionChat Add<CR>",
				desc = "Add code to a chat buffer",
				mode = { "v" },
			},
		}
	end,
	init = function()
		vim.cmd([[cab cc CodeCompanion]])
		require("plugins.custom.spinner"):init()
	end,
}
