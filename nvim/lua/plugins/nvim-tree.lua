return {

  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  init = function ()
    -- turn off netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- set termguicolors to enable highlight groups
    vim.opt.termguicolors = true
  end,

  keys = {
    -- This declares the keymap in a lazy-aware way (shows up in which-key/help UIs)
    { "<leader>pv", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" },
  },

  config = function()
    require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 35,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
    })

     local function open_nvim_tree(data)
       -- buffer is a directory
       local directory = vim.fn.isdirectory(data.file) == 1

       if not directory then
         return
       end

       -- change to the directory
       vim.cmd.cd(data.file)

       -- open the tree
       require("nvim-tree.api").tree.open()
    end
  end,

}

