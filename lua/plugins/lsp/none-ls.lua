return {
	"nvimtools/none-ls.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvimtools/none-ls-extras.nvim",
		"gbprod/none-ls-shellcheck.nvim",
	},
	config = function()
		-- IMPORTANT!
		local augroup = vim.api.nvim_create_augroup("NoneLsFormatting", {})

		local on_attach = function(client, bufnr)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = augroup,
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ bufnr = bufnr })
					end,
				})
			end
		end

		local methods = require("null-ls.methods")
		local h = require("null-ls.helpers")

		local gcc = {
			method = methods.internal.DIAGNOSTICS,
			filetypes = { "c", "cpp" },
			name = "gcc",
			async = true,
			generator = h.generator_factory({
				command = "gcc",
				args = {
					"-std=c89",
					"-Wall",
					"-Wpedantic",
					"$FILENAME",
					"-o /dev/null",
				},
				to_stdin = false,
				from_stderr = true,
				format = "line",
				on_output = h.diagnostics.from_pattern(
					[[^([^:]+):(%d+):(%d+):%s+([^:]+):%s+(.*)$]],
					-- [[(%w+):(%d+):(%d+): (%w+): (.*)]],
					{ "file", "row", "col", "severity", "message" },
					{
						severities = {
							["fatal error"] = h.diagnostics.severities.error,
							["error"] = h.diagnostics.severities.error,
							["note"] = h.diagnostics.severities.information,
							["warning"] = h.diagnostics.severities.warning,
						},
					}
				),
			}),
		}

		local nl = require("null-ls")
		local sources = {
			require("none-ls.formatting.jq"),

			require("none-ls.formatting.beautysh"),
			require("none-ls-shellcheck.diagnostics"),
			require("none-ls-shellcheck.code_actions"),

			require("none-ls.diagnostics.eslint_d"),
			require("none-ls.code_actions.eslint_d"),

			require("none-ls.diagnostics.flake8"),

			nl.builtins.diagnostics.mypy,
			nl.builtins.formatting.black,

			nl.builtins.formatting.stylua,
			nl.builtins.formatting.prettier,

			gcc,
		}
		nl.setup({
			sources = sources,
		})

		on_attach = on_attach
	end,
}
