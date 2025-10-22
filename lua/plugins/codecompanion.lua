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
				default = "gemini-2.5-pro",
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
	anthropic = anthropic_fn,
	openai = openai_fn,
	gemini = gemini_fn,
	deepseek = deepseek_fn,
	ollama = ollama_fn,
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
		require("codecompanion").setup({
			opts = {
				-- Set debug logging
				show_defaults = true,
				--                log_level = "DEBUG",
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
					show_settings = true,
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
					prompts = {
						{
							role = "system",
							content = [[Analyze the code for:

### CODE QUALITY
* Function and variable naming (clarity and consistency)
* Code organization and structure
* Documentation and comments
* Consistent formatting and style

### RELIABILITY
* Error handling and edge cases
* Resource management
* Input validation

### MAINTAINABILITY
* Code duplication (but don't overdo it with DRY, some duplication is fine)
* Single responsibility principle
* Modularity and dependencies
* API design and interfaces
* Configuration management

### PERFORMANCE
* Algorithmic efficiency
* Resource usage
* Caching opportunities
* Memory management

### SECURITY
* Input sanitization
* Authentication/authorization
* Data validation
* Known vulnerability patterns

### TESTING
* Unit test coverage
* Integration test needs
* Edge case testing
* Error scenario coverage

### POSITIVE HIGHLIGHTS
* Note any well-implemented patterns
* Highlight good practices found
* Commend effective solutions

Format findings as markdown and with:
- Issue: [description]
- Impact: [specific impact]
- Suggestion: [concrete improvement with code example/suggestion]

              ]],
						},
						{
							role = "user",
							content = "Please review provided code.\n" .. "#buffer #lsp",
						},
					},
				},
			},
		})

		local fidget = require("fidget")
		local handler
		if fidget then
			vim.api.nvim_create_autocmd({ "User" }, {
				pattern = "CodeCompanionRequest*",
				group = vim.api.nvim_create_augroup("CodeCompanionHooks", {}),
				callback = function(request)
					if request.match == "CodeCompanionRequestStarted" then
						if handler then
							handler.message = "Abort."
							handler:cancel()
							handler = nil
						end
						handler = fidget.progress.handle.create({
							title = "",
							message = "Thinking...",
							lsp_client = { name = "CodeCompanion" },
						})
					elseif request.match == "CodeCompanionRequestFinished" then
						if handler then
							handler.message = "Done."
							handler:finish()
							handler = nil
						end
					end
				end,
			})
		end
	end,
	keys = function()
		return {
			{ "<leader>ac", ":CodeCompanionChat anthropic<CR>", desc = "Codecompanion: Claude" },
			{ "<leader>ao", ":CodeCompanionChat openai<CR>", desc = "Codecompanion: OpenAI" },
			{ "<leader>ag", ":CodeCompanionChat gemini<CR>", desc = "Codecompanion: Gemini" },
			{ "<leader>al", ":CodeCompanionChat ollama<CR>", desc = "Codecompanion: Ollama" },

			{ "<leader>at", ":CodeCompanionChat Toggle<CR>", desc = "Codecompanion toggle" },
			{
				"<leader>aS",
				function()
					local name = vim.fn.input("Save as: ")
					if name and name ~= "" then
						vim.cmd("CodeCompanionSave " .. name)
					end
				end,
				desc = "Codecompanion Save chat",
			},
			{ "<leader>aL", ":CodeCompanionLoad<CR>", desc = "Codecompanion Load chat" },
			{ "<leader>aP", ":CodeCompanionActions<CR>", desc = "Codecompanion Prompts" },
		}
	end,
}
