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
				return os.getenv("GEMINI_KEY")
			end,
		},
		schema = {
			model = {
				default = "gemini-2.5-flash-preview-04-17",
			},
			num_ctx = {
				default = 16386,
			},
			num_predict = {
				default = -1,
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

local function save_path()
	local Path = require("plenary.path")
	local p = Path:new(vim.fn.stdpath("data") .. "/codecompanion_chats")
	p:mkdir({ parents = true })
	return p
end

--- Load a saved codecompanion.nvim chat file into a new CodeCompanion chat buffer.
--- Usage: CodeCompanionLoad
vim.api.nvim_create_user_command("CodeCompanionLoad", function()
	local fzf = require("fzf-lua")

	local function select_adapter(filepath)
		local adapters = vim.tbl_keys(supported_adapters)

		fzf.fzf_exec(adapters, {
			prompt = "Select CodeCompanion Adapter> ",
			actions = {
				["default"] = function(selected)
					local adapter = selected[1]
					-- Open new CodeCompanion chat with selected adapter
					vim.cmd("CodeCompanionChat " .. adapter)

					-- Read contents of saved chat file
					local lines = vim.fn.readfile(filepath)

					-- Get the current buffer (which should be the new CodeCompanion chat)
					local current_buf = vim.api.nvim_get_current_buf()

					-- Paste contents into the new chat buffer
					vim.api.nvim_buf_set_lines(current_buf, 0, -1, false, lines)
				end,
			},
		})
	end

	local function start_picker()
		local files = vim.fn.glob(save_path() .. "/*", false, true)

		fzf.fzf_exec(files, {
			prompt = "Saved CodeCompanion Chats | <c-r>: remove >",
			previewer = "builtin",
			actions = {
				["default"] = function(selected)
					if #selected > 0 then
						local filepath = selected[1]
						select_adapter(filepath)
					end
				end,
				["ctrl-r"] = function(selected)
					if #selected > 0 then
						local filepath = selected[1]
						os.remove(filepath)
						-- Refresh the picker
						start_picker()
					end
				end,
			},
		})
	end

	start_picker()
end, {})

--- Save the current codecompanion.nvim chat buffer to a file in the save_folder.
--- Usage: CodeCompanionSave <filename>.md
---@param opts table
vim.api.nvim_create_user_command("CodeCompanionSave", function(opts)
	local codecompanion = require("codecompanion")
	local success, chat = pcall(function()
		return codecompanion.buf_get_chat(0)
	end)
	if not success or chat == nil then
		vim.notify(
			"CodeCompanionSave should only be called from CodeCompanion chat buffers",
			vim.log.levels.ERROR
		)
		return
	end
	if #opts.fargs == 0 then
		vim.notify("CodeCompanionSave requires at least 1 arg to make a file name", vim.log.levels.ERROR)
	end
	local save_name = table.concat(opts.fargs, "-") .. ".md"
	local save_file = save_path():joinpath(save_name)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	save_file:write(table.concat(lines, "\n"), "w")
end, { nargs = "*" })

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
								provider = "fzf_lua", -- default|telescope|mini_pick|fzf_lua
							},
						},

						["file"] = {
							opts = {
								provider = "fzf_lua", -- default|telescope|mini_pick|fzf_lua
							},
						},

						["help"] = {
							opts = {
								provider = "fzf_lua", -- telescope|mini_pick|fzf_lua
							},
						},

						["symbols"] = {
							opts = {
								provider = "fzf_lua", -- default|telescope|mini_pick|fzf_lua
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
					provider = "default", -- default|mini_diff
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
							content = "Please make the following changes using #buffer with @editor\n\n",
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
