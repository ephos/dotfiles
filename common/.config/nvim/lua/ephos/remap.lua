-- Use space-pv to enter netrw 
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>pb", vim.cmd.Vex)

-- Change Nvim copy paste to use system clipboard
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>p", '"+p')
vim.keymap.set("v", "<leader>p", '"+p')

-- Update "d" so deletion is not saved to register
vim.keymap.set("n", "d", '"_d')

-- Disable recording
vim.keymap.set("n", "q", "<nop>")

-- Move lines with Alt+j/k
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")

-- Walk through errors
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })

-- Messing around
--vim.keymap.set("n", "<leader>b", function ()
--    print("You're doing great Rob!")
--end)
