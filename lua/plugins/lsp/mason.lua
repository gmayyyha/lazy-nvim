return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        -- import mason
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        mason.setup({
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        mason_lspconfig.setup({
            ensure_installed = {
                "clangd",
                --                "pylsp",
                "lua_ls",
                "rust_analyzer",
                "gopls",
                --                "jedi_language_server",
                "pyright",
                "bashls",
                "jsonls",
                "yamlls",
                "vimls",
                "ansiblels",
                "html",
                "cssls",
            },
        })

        mason_tool_installer.setup({
            ensure_installed = {
                "black",
                "isort",
                "prettier",
                "stylua",
                "pylint",
                "eslint_d",
                "cpplint",
                "clang-format",
                "shellcheck",
            },
        })
    end,
}
