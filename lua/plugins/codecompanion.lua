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
        local default_model = "gemini-2.5-flash-preview-04-17"
        local available_models = {
            "gemini-2.5-flash-preview-04-17",
            "google/gemini-2.0-flash-001",
            "google/gemini-2.5-pro-preview-03-25",
            "anthropic/claude-3.7-sonnet",
            "anthropic/claude-3.5-sonnet",
            "openai/gpt-4o-mini",
        }
        local current_model = default_model

        local function select_model()
            vim.ui.select(available_models, {
                prompt = "Select  Model:",
            }, function(choice)
                if choice then
                    current_model = choice
                    vim.notify("Selected model: " .. current_model)
                end
            end)
        end
        require("codecompanion").setup({
            opts = {
                -- Set debug logging
                show_defaults = true,
                log_level = "DEBUG",
            },
            adapters = {
                deepseek = function()
                    return require("codecompanion.adapters").extend("openai_compatible", {
                        name = "deepseek",
                        env = {
                            url = "https://api.deepseek.com",
                            api_key = function()
                                return os.getenv("DEEPSEEK_KEY")
                            end,
                        },
                    })
                end,
                google = function()
                    return require("codecompanion.adapters").extend("openai_compatible", {
                        name = "google",
                        url = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
                        env = {
                            api_key = function()
                                return os.getenv("GEMINI_KEY")
                            end,
                        },
                        schema = {
                            model = {
                                default = current_model,
                                choices = {
                                    ["gemini-2.5-flash-preview-04-17"] = { opts = { can_reason = true } },
                                    "gemini-2.5-pro-preview-03-25",
                                },
                            },
                        },
                    })
                end,
                deepseek_ollama = function()
                    return require("codecompanion.adapters").extend("ollama", {
                        name = "ollama-r1-14b",
                        schema = {
                            model = {
                                default = "deepseek-r1:14b",
                            },
                            num_ctx = {
                                default = 16384,
                            },
                            num_predict = {
                                default = -1,
                            },
                        },
                    })
                end,
            },
            strategies = {
                chat = { adapter = "google" },
                inline = { adapter = "google" },
                agent = { adapter = "siliconflow" },
            },
        })

        local keymap = vim.keymap.set

        keymap({ "n", "v", "x" }, "<leader>cp", ":CodeCompanionActions<CR>")

        keymap({ "n", "v" }, "<leader>ck", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
        keymap({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
        keymap("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

        keymap("n", "<leader>cm", select_model, { desc = "Select Gemini Model" })
        -- Expand 'cc' into 'CodeCompanion' in the command line
        vim.cmd([[cab cc CodeCompanion]])

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
}
