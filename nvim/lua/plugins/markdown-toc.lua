return {
    "hedyhli/markdown-toc.nvim",
    ft = "markdown", -- only load on markdown
    opts = {
        toc_list = {
            markers = { '*', '+', '-' },
            cycle_markers = true,
        },
        auto_update = true,
    },
}
