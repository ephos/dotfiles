--vim.g.copilot_filetypes = {
--    xml = false,
--    markdown = false
--}
--
--vim.cmd[[highlight CopilotSuggestion guifg=#5374a6 ctermfg=8]]
--vim.g.copilot_no_tab_map = true
----vim.keymap.set("i", "<C-m>", ":copilot#Accept<CR>", {silent = true})
--vim.cmd[[imap <silent><script><expr> <C-/> copilot#Accept("\<CR>")]]
--vim.keymap.set('i', '<C-.>', '<Plug>(copilot-next)')
--vim.keymap.set('i', '<C-,>', '<Plug>(copilot-previous)')

require("copilot").setup({
  suggestion = { enabled = true },
  panel = { enabled = false },
})

require("copilot_cmp").setup()
