-- Core Settings
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.updatetime = 50
vim.g.have_nerd_font = 1

-- Lines
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false

-- Visual Indictaor
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = "#00ffc8" })
vim.opt.signcolumn = "yes"

-- Tabbin' Yo
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Line Length Indictaor
vim.opt.colorcolumn = "80"

-- Searching
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true

-- Terminal
vim.opt.termguicolors = true

-- Scrolling/History
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5

-- Netrw
vim.g.netrw_banner = 1
vim.g.netrw_winsize = 80
vim.g.netrw_browse_split = 20
vim.g.netrw_liststyle = 3
vim.g.netrw_sizestyle = "H"
--vim.g.netrw_browse_split = 4 -- Open in previous window
vim.g.netrw_preview = 1

