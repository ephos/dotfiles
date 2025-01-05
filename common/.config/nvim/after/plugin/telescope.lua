local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', "<leader>pd", "<cmd>Telescope diagnostics<cr>")
vim.keymap.set('n', '<leader>gd', builtin.lsp_definitions, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

local telescope = require('telescope')

telescope.setup {
  defaults = {
    -- Your default config goes here...
  },
}

-- Custom picker for Godot below, requires `rg`
local M = {}

M.search_gd_files = function()
  require('telescope.builtin').find_files({
    prompt_title = '< GD Files >',
    find_command = {
      'rg',
      '--files',        -- List files that would be searched but do not search
      '--color=never',  -- Do not use color in rg output
      '--glob', '*.gd', -- Search only for .gd files
      '--glob', '!game_object/*'  -- Exclude game_object directory
    }
  })
end

telescope.search_gd_files = M.search_gd_files

vim.keymap.set('n', '<leader>pg', ':lua require("telescope").search_gd_files()<CR>', { noremap = true, silent = true })


