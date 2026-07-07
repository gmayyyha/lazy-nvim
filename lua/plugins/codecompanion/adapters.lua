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
				default = "gemini-3.1-flash-lite",
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
	opts = {
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
	},
}
