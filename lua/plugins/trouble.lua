return {
    "folke/trouble.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "folke/todo-comments.nvim",
    },
    keys = {
        { "<leader>xx", "<cmd>TroubleToggle<CR>", desc = "Open/Close trouble list" },
        { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", desc = "Open trouble workspace_diagnostics list" },
        { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>", desc = "Open trouble document_diagnostics list" },
        { "<leader>xq", "<cmd>TroubleToggle quickfix<CR>", desc = "Open trouble quickfix list" },
        { "<leader>xl", "<cmd>TroubleToggle loclist<CR>", desc = "Open trouble location list" },
        { "<leader>xt", "<cmd>TodoTrouble<CR>", desc = "Open todos in trouble"}
    }
}
