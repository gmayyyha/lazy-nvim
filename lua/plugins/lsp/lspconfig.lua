return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
    },
    config = function()
        local lspconfig = require("lspconfig")
        local mason_lspconfig = require("mason-lspconfig")

        local keymap = vim.keymap

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                -- Buffer local mappings.
                -- See `:help vim.lsp.*`
                local opts = { buffer = ev.buf, silent = true }

                -- set keybinds
                opts.desc = "Show LSP references"
                keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definitions, references

                opts.desc = "Go to LSP definition"
                keymap.set("n", "gD", vim.lsp.buf.definition, opts) -- go to definition

                opts.desc = "Show LSP definitions"
                keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show definitions

                opts.desc = "Show LSP implementation"
                keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show implementations

                opts.desc = "Show LSP type definitions"
                keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show type definitions

                opts.desc = "See available code actions"
                keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions

                opts.desc = "Smart rename"
                keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

                opts.desc = "Show buffer diagnostics"
                keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show diagnostics

                opts.desc = "Show line diagnostics"
                keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics

                opts.desc = "Go to previous diagnostic"
                keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- go to previous diagnostic

                opts.desc = "Go to next diagnostic"
                keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- go to next diagnostic

                opts.desc = "Show document diagnostics"
                keymap.set("n", "<leader>K", vim.lsp.buf.hover, opts) -- show documentation

                opts.desc = "Restart LSP"
                keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- restart LSP
            end,
        })

        -- use to enable autocompletion (assign to every lsp server config)
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        local util = require("lspconfig.util")

        -- Change the Diagnostic symbols in the sign column (gutter)
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- used to ensure hover displays with borders
        local handlers = {
            ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
            ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
        }

        mason_lspconfig.setup_handlers({
            function(server)
                lspconfig[server].setup({
                    capabilities = capabilities,
                })
            end,
            ["clangd"] = function()
                local root_files = {
                    ".clangd",
                    ".clang-tidy",
                    ".clang-format",
                    ".git",
                    "compile_commands.json",
                    "CMakeLists.txt",
                    "compile_flags.txt",
                    "Makefile",
                    "configure.ac", -- AutoTools
                }

                lspconfig["clangd"].setup({
                    capabilities = capabilities,
                    handlers = handlers,
                    on_attach = function(client, _)
                        -- Disable LSP formatting
                        client.server_capabilities.documentFormattingProvider = false
                        --                        client.server_capabilities.signatureHelpProvider = false
                        --                        client.server_capabilities.semanticTokensProvider = nil
                    end,
                    filetypes = { "h", "hpp", "c", "cc", "cpp", "objc", "objcpp", "cuda", "proto" },
                    root_dir = function(fname)
                        return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
                    end,
                    single_file_support = true,
                    cmd = {
                        "/usr/bin/clangd",
                        --                        "--log=verbose",
                        "--query-driver=/usr/bin/clang",
                        "--background-index=false",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                    },
                })
            end,

            ["pyright"] = function()
                local path = util.path
                lspconfig["pyright"].setup({
                    capabilities = capabilities,
                    on_attach = function(client, _)
                        -- Disable LSP formatting
                        client.server_capabilities.documentFormattingProvider = false
                        --                        client.server_capabilities.signatureHelpProvider = false
                        --                        client.server_capabilities.semanticTokensProvider = nil
                    end,
                    cmd = { "pyright-langserver", "--stdio" },
                    filetypes = { "python" },
                    root_dir = util.root_pattern(
                        "pyproject.toml",
                        "setup.py",
                        "setup.cfg",
                        "requirements.txt",
                        "Pipfile",
                        "pyrightconfig.json"
                    ),
                    on_init = function(client)
                        default_env_path = path.join(vim.env.VIRTUAL_ENV)
                        client.config.settings.python.PythonPath = path.join(default_env_path, "bin", "python")
                        client.config.settings.python.venvPath = default_env_path
                    end,
                })
            end,
            -- ["lua_ls"] = function()
            --     lspconfig["lua_ls"].setup({
            --         handlers = handlers,
            --         capabilities = capabilities,
            --         settings = {
            --             Lua = {
            --                 completion = {
            --                     callSnippet = "Replace",
            --                 },
            --                 diagnostics = {
            --                     globals = { "vim" },
            --                 },
            --             },
            --         },
            --     })
            -- end,
            -- ["gopls"] = function()
            --     lspconfig["gopls"].setup({
            --         handlers = handlers,
            --         capabilities = capabilities,
            --         cmd = { "gopls" },
            --         filetypes = { "go", "gomod", "gowork", "gotmpl" },
            --         root_dir = util.root_pattern("go.work", "go.mod"),
            --         settings = {
            --             gopls = {
            --                 completeUnimported = true,
            --                 usePlaceholders = true,
            --                 analyses = {
            --                     unusedparams = true,
            --                 },
            --             },
            --         },
            --     })
            -- end,
        })
    end,
}
