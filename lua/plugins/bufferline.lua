return {
    "akinsho/bufferline.nvim",
    depenndencies = {
        "nvim-tree/nvim-web-devicons",
        { "echasnovski/mini.nvim", version = false },
    },
    version = "*",

    config = function()
        local bufferline = require("bufferline")
        bufferline.setup({
            options = {
                separator_style = "slant",
                close_command = "bdelete! %d", -- can be a string | function, | false see "Mouse actions"
                buffer_close_icon = "󰅖",
                modified_icon = "●",
                close_icon = "",
                left_trunc_marker = "",
                right_trunc_marker = "",
                diagnostics = "nvim_lsp",
            },
        })

        local keymap = vim.keymap

        keymap.set("n", "<C-l>", ":bnext<CR>", { desc = "Go to next buffer" })
        keymap.set("n", "<C-h>", ":bprevious<CR>", { desc = "Go to previous buffer" })
        keymap.set("n", "<C-x>", ":bd<CR>", { desc = "Close current buffer" })
    end,
}
