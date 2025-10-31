-------------------------------------------------
-- Global
-------------------------------------------------
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "When text is yanked, highlight the selection",
    group = vim.api.nvim_create_augroup("highlight_yank", {clear = true}),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-------------------------------------------------
-- Global
-------------------------------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = '*',
    callback = function (args)
        vim.lsp.buf.format({ bufnr = args.bug })
    end

})


-------------------------------------------------
-- Language Preferences
-------------------------------------------------
-- Markdown spacing
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end
})

-- A function to refresh Go when adding a new package to avoid 'could not import'
go_mod_tidy = function()
  vim.cmd([[ ! go mod tidy ]])
  vim.cmd([[ LspRestart ]])
end

vim.api.nvim_command('command! GoModTidy lua go_mod_tidy()')

