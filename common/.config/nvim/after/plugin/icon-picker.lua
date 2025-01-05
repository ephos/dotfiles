require("icon-picker").setup({
  disable_legacy_commands = true
})

local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<D-.>", "<cmd>IconPickerNormal emoji<cr>", opts)
vim.keymap.set("n", "<Leader><Leader>y", "<cmd>IconPickerYank emoji<cr>", opts) --> Yank the selected icon into register
vim.keymap.set("i", "<D-.>", "<cmd>IconPickerInsert emoji<cr>", opts)
