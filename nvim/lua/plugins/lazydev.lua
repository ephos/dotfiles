-- This plugin is specifically for Neovim config things
-- Specifically the lua_ls LSP complaining about the `vim.` global and adding vim api specific autocomplete.
-- Honestly for that alone it's worth it, I actually don't know what else it does.
return {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
        library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
    },
}
