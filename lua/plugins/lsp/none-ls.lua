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

        local nl = require("null-ls")
        local sources = {
            require("none-ls.formatting.jq"),

            require("none-ls.formatting.beautysh"),
            require("none-ls-shellcheck.diagnostics"),
            require("none-ls-shellcheck.code_actions"),

            require("none-ls.diagnostics.eslint_d"),
            require("none-ls.code_actions.eslint_d"),

            require("none-ls.diagnostics.flake8"),

            nl.builtins.formatting.stylua,
            nl.builtins.formatting.prettier,
        }
        nl.setup({
            sources = sources,
        })

        on_attach = on_attach
    end,
}
