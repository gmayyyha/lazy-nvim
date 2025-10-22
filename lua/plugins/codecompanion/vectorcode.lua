return {
	{
		"Davidyz/VectorCode",
		version = "*", -- optional, depending on whether you're on nightly or release
		build = "python -m pipx upgrade vectorcode", -- optional but recommended. This keeps your CLI up-to-date.
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	{
		"olimorris/codecompanion.nvim",
		opts = {
			extensions = {
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
		},
	},
}
