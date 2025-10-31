return {
    'nvim-telescope/telescope.nvim', 
    tag = '0.1.8',
    lazy = false,
    dependencies = {
        'nvim-lua/plenary.nvim'
    },

    init = function ()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', "<leader>pd", "<cmd>Telescope diagnostics<cr>")
        vim.keymap.set('n', '<leader>gd', builtin.lsp_definitions, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end, {})
    end,

    keys = {
        { "<leader>pv", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" },
    },

    --opts = {}

    config = function()
        require('telescope').setup({
            defaults = {}
        })
    end,
}
