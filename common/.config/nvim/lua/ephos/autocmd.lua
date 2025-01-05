-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "When text is yanked, highlight the selection",
    group = vim.api.nvim_create_augroup("highlight_yank", {clear = true}),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Set autoformat on save
--[[
vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buffer,
    callback = function()
        vim.lsp.buf.format { async = false }
    end
})
--]]
