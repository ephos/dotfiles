return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
        -- FIX 1: The module path has changed on the main branch
        local ts = require('nvim-treesitter')

        -- FIX 2: Force Git to avoid the tarball extraction errors from before
        require("nvim-treesitter.install").prefer_git = true

        ts.setup({
            -- 'help' is now 'vimdoc' in 0.12+
            ensure_installed = {
                "c", "css", "bash", "dockerfile", "gdscript", "gdshader",
                "godot_resource", "go", "vimdoc", "html", "json", "lua",
                "markdown", "markdown_inline", "powershell", "python", "regex",
                "ruby", "rust", "vim", "yaml", "zig",
            },

            sync_install = false,
            auto_install = true,

            highlight = {
                enable = true,
                -- Setting this to true is usually what breaks Markdown in 0.12
                additional_vim_regex_highlighting = false,
            },
        })
    end,
}



-- [
-- # Remove the plugin code itself so Lazy.nvim forces a fresh clone of 'main'
-- rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
--
-- # Remove all old compiled parsers (crucial for Arch 12.1)
-- rm -rf ~/.local/share/nvim/tree-sitter-parsers
-- ]
