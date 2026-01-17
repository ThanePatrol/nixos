require('nvim-treesitter.configs').setup({
    highlight = {enable = true},
    rainbow = {enable = true, extended_mode = true, max_file_lines = 5000},
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<leader>ss", -- selection start
            node_incremental = "<leader>sd",
            scope_incremental = false,
            node_decremental = "<leader>sa"
        }
    }
})
