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
		-- local augroup = vim.api.nvim_create_augroup("NoneLsFormatting", {})
		--
		-- local on_attach = function(client, bufnr)
		-- 	if client.supports_method("textDocument/formatting") then
		-- 		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		-- 		vim.api.nvim_create_autocmd("BufWritePre", {
		-- 			group = augroup,
		-- 			buffer = bufnr,
		-- 			callback = function()
		-- 				vim.lsp.buf.format({ bufnr = bufnr })
		-- 			end,
		-- 		})
		-- 	end
		-- end

		local methods = require("null-ls.methods")
		local h = require("null-ls.helpers")

		local gcc_custom_diagnostics = {
			name = "gcc_custom_diagnostics",
			method = methods.internal.DIAGNOSTICS, -- 指定这是一个诊断源
			filetypes = { "c", "cpp" },
			async = true,
			-- 生成命令行参数的函数
			generator = h.generator_factory({
				command = function(params)
					if params.filetype == "cpp" then
						return "g++" -- 或你系统上的 g++ 可执行文件路径
					else
						return "gcc" -- 或你系统上的 gcc 可执行文件路径
					end
				end,
				args = function(params)
					local base_args = {
						"-fsyntax-only", -- 只检查语法，不生成目标文件
						"-Wall",
						"-Wextra",
						"-Wpedantic",
						-- "-fno-diagnostics-show-caret", -- 可选，有时简化输出
						"-c", -- 编译但不链接
						params.filename, -- 当前文件名
						"-o",
						"/dev/null", -- 将输出重定向到 /dev/null (或 NUL on Windows)
					}

					-- 添加特定于文件类型的标准
					if params.filetype == "cpp" then
						table.insert(base_args, "-std=c++17") -- 或者你需要的 C++ 标准
					else
						table.insert(base_args, "-std=c89") -- 或者你需要的 C 标准
					end

					-- !!! 处理包含路径和其他项目特定标志 (最困难的部分) !!!
					-- 示例：添加当前工作目录下的 'include' 文件夹
					local project_include_dir = vim.fn.getcwd() .. "/include"
					if vim.fn.isdirectory(project_include_dir) == 1 then
						table.insert(base_args, "-I" .. project_include_dir)
					end

					-- 示例：从一个名为 .gcc_flags.txt 的文件中读取额外参数 (每行一个)
					-- 这只是一个示例，你需要根据你的项目调整
					local flags_file = vim.fn.getcwd() .. "/.gcc_flags.txt"
					if vim.fn.filereadable(flags_file) == 1 then
						for line in io.lines(flags_file) do
							if line ~= "" and not line:match("^%s*#") then
								table.insert(base_args, line)
							end
						end
					end
					-- 你可能还需要从环境变量、项目局部配置等地方获取更复杂的编译标志

					return base_args
				end,
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

			--                      require("none-ls.formatting.beautysh"),
			require("none-ls-shellcheck.diagnostics"),
			require("none-ls-shellcheck.code_actions"),

			--                  require("none-ls.diagnostics.eslint_d"),
			--                  require("none-ls.code_actions.eslint_d"),

			--                      require("none-ls.diagnostics.flake8"),

			nl.builtins.diagnostics.mypy,
			nl.builtins.formatting.black,

			nl.builtins.formatting.stylua,
			nl.builtins.formatting.prettier,

			gcc_custom_diagnostics,
		}
		nl.setup({
			sources = sources,
		})

		--		on_attach = on_attach
	end,
}
