--return {
--    "catgoose/nvim-colorizer.lua",
--    --lazy = false,
--    event = "BufReadPre",
--
--    config = function()
--        require("colorizer").setup({
--            filetypes = { '*' },
--            user_default_options = {
--                names = false,
--                RBG = true,
--                RGBA = true,
--                RRGGBB = true,
--            },
--        })
--    end
--} 

return {
  "catgoose/nvim-colorizer.lua",
  --event = "BufReadPre",
  init = function()
    -- ensure this is set before plugin runs
    vim.o.termguicolors = true
  end,
  opts = {
    filetypes = { "*" },
    user_default_options = {
      names = false,      -- disable named colors globally
      RGB = true,
      RGBA = true,
      RRGGBB = true,
      RRGGBBAA = true,
      AARRGGBB = true,
      rgb_fn = true,
      hsl_fn = true,
      -- mode = "background", -- try "virtualtext" if you want a quick visual check
    },
  },
}

