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
                siliconflow = function()
                    return require("codecompanion.adapters").extend("deepseek", {
                        name = "siliconflow",
                        url = "https://api.siliconflow.com/v1/chat/completions",
                        env = {
                            api_key = function()
                                return os.getenv("SILICONFLOW_KEY")
                            end,
                        },
                        schema = {
                            model = {
                                default = "deepseek-ai/DeepSeek-R1",
                                choices = {
                                    ["deepseek-ai/DeepSeek-R1"] = { opts = { can_reason = true } },
                                    "deepseek-ai/DeepSeek-V3",
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
                chat = { adapter = "siliconflow" },
                inline = { adapter = "siliconflow" },
                agent = { adapter = "siliconflow" },
            },
        })

        local keymap = vim.keymap.set

        keymap({ "n", "v", "x" }, "<leader>ai", function()
            require("codecompanion").toggle()
        end)

        keymap({ "n", "v", "x" }, "<leader>cp", ":CodeCompanionActions<CR>")

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
