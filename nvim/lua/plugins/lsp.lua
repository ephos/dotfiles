return {
    -- mason-lspconfig
    "mason-org/mason-lspconfig.nvim",
    opts = {
        ensure_installed = {
            "lua_ls",
            "gopls",
            "marksman",
            "pyright",
            "terraformls",
            "powershell_es",
            "zls",
        },
    },
    dependencies = {
        {
            -- Mason has to load before mason-lspconfig
            "mason-org/mason.nvim",
            opts = {
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            }
        },
        -- neovim/nvim-lspconfig has to load before all mason plugins
        "neovim/nvim-lspconfig",
    },
}
