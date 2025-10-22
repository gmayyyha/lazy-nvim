return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"saghen/blink.cmp",
			{
				"folke/lazydev.nvim",
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},

		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			local keymap = vim.keymap

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Buffer local mappings.
					-- See `:help vim.lsp.*`
					local opts = { buffer = ev.buf, silent = true }

					-- set keybinds
					opts.desc = "Show LSP references"
					keymap.set("n", "gR", vim.lsp.buf.references, opts) -- show definitions, references

					opts.desc = "Go to LSP definition"
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to definition

					opts.desc = "Show LSP definitions"
					keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show definitions

					opts.desc = "Show LSP implementation"
					keymap.set("n", "gi", vim.lsp.buf.implementation, opts) -- show implementations

					opts.desc = "Show LSP type definitions"
					keymap.set("n", "gt", vim.lsp.buf.type_definition, opts) -- show type definitions

					opts.desc = "See available code actions"
					keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions

					opts.desc = "Smart rename"
					keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

					opts.desc = "Show buffer diagnostics"
					keymap.set("n", "<leader>D", function()
						vim.diagnostic.setloclist({
							open = true, -- 自动打开位置列表窗口
							-- severity = vim.diagnostic.severity.WARN, -- 可选: 只显示警告及以上级别
							-- scope = "buffer", -- 默认就是 buffer，可以省略
						})
					end, opts) -- show diagnostics

					opts.desc = "Open location list"
					keymap.set("n", "<leader>lo", "<cmd>lopen<CR>", opts)

					opts.desc = "Close location list"
					keymap.set("n", "<leader>lc", "<cmd>lclose<CR>", opts)

					opts.desc = "Show line diagnostics"
					keymap.set("n", "<leader>dl", function()
						vim.diagnostic.open_float(nil, {
							scope = "line", -- "cursor" 仅光标位置, "line" 整行
							focusable = true, -- 使浮动窗口可聚焦以便滚动
							source = "if_multiple", -- "always", "if_multiple", "never" (是否显示诊断来源)
							header = "", -- 可选: 自定义浮动窗口头部
							border = "rounded", -- 可选: 边框样式，如 "none", "single", "double", "rounded"
							-- format = function(diagnostic) -- 可选: 自定义每个诊断条目的显示格式
							--   return string.format("[%s] %s (%s)", diagnostic.severity, diagnostic.message, diagnostic.source)
							-- end,
						})
					end, opts) -- show diagnostics

					opts.desc = "Show document diagnostics"
					keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation

					opts.desc = "Restart LSP"
					keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- restart LSP
				end,
			})

			local on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup(
							"FormatOnSaveNullLs_" .. bufnr,
							{ clear = true }
						),
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({
								bufnr = bufnr,
								async = true,
								filter = function(c)
									return c.name == "null-ls"
								end,
							})
						end,
					})
					--					print("None-ls: Formatting on save enabled for buffer " .. bufnr)
				end
			end

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			vim.lsp.config("pyright", {
				capabilities = capabilities,
				-- on_attach = on_attach,
			})

			vim.lsp.config("ruff", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			vim.lsp.config("gopls", {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "gopls" },
				settings = {
					gopls = {
						completeUnimported = true,
						usePlaceholders = true,
						analyses = {
							unusedparams = true,
						},
					},
				},
			})

			vim.lsp.config("clangd", {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = {
					"clangd",
					"--compile-commands-dir=./build", -- (可选) 如果你的 compile_commands.json 不在项目根目录
					"--query-driver=/usr/bin/gcc,/usr/bin/g++", -- (可选) 如果你的项目用 GCC 编译
					-- "--all-scopes-completion",
					-- "--pch-storage=memory",
					-- "--clang-tidy",
					-- "--completion-style=detailed",
				},
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
			})
		end,
	},
}
