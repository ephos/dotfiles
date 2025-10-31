# Bobby Bologna's Neovim Config Extravaganza

## Notes on the Layout

- I do not separate my LSP related plugins (mason etc.). It doesn't feel right just to have another folder for the sake of it
- I am deciding to use _neovim/nvim-lspconfig_ as it still provides sensible defaults and I rarely override LSP settings
  * Check the ['LSP-y things'](#LSP-y-things) section on LSP overrides!
- I have also decided to let mason-lspconfig just load the LSPs.

## Loading Up

1. init.lua loads the important shit
  a. Load up the config (lua/pkg/lazy.lua) for lazy.nvim, this is our package manager.  RIP Packer
  b. Load up the core (lua/core/*.lua) configs, QoL stuff for reasonable people like relative line numbers

## LSP-y things

What to know:

- **All LSP _plugins_ are loaded from ./nvim/lua/plugins/lsp.lua!!**
- `mason` is used to install LSPs
- `mason-lspconfig` is used to auto-install AND load LSPs
- `nvim-lspconfig` is in use to provide sensible defaults
- All LSPs are loaded from ./nvim/lua/plugin/lsp.lua via `mason-lspconfig`!
  * These are the actual LSPs, unless override they'll be the defaults provided by nvim-lspconfig.
  * See overrides below, or also just look at the comments in that file.
 
### mason-org/mason.nvim

A.K.A. Mason. We always use this to install our LSPs, who uses anything else??

### mason-org/mason-lspconfig.nvim

This is what will auto-download the LSPs, why should you have to do all the work when Mason does it for you??
This plugin alleviates needing the following file loaded by init (generally something like nvim/lua/core/lsp.lua)

```lua
-- The following take defaults from neovim/nvim-lspconfig
-- [Configs](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md)
-- The configs below MUST match the filename from that link above, thems just the rules dude.
vim.lsp.enable("lua_ls");
vim.lsp.enable("gopls");
vim.lsp.enable("marksman");
vim.lsp.enable("pyright");
vim.lsp.enable("terraformls");
vim.lsp.enable("zls");

-- The following are overridden from neovim/nvim-lspconfig
-- All enabled LSPs need to match the file name in ./after/lsp/<name>.lua
vim.lsp.enable("powershell_es");
```

If you want to remove mason-lspconfig and return to loading the LSPs yourself do the following:

1. Create the file ~/.config/nvim/lua/core/lsp.lua
2. Add a code snip similar to above to it
3. If you aren't using `mason-lspcolnfig` OR `nvim-lspconfig` you have to define an LSP lua file for each config

### neovim/nvim-lspconfig

I am opting into using defaults as defined [here](https://github.com/neovim/nvim-lspconfig/tree/master/lsp)

- The model without this plugin is that all the defined LSP configs would live in:
  * _~/.config/nvim/lsp/<lsp_filename.lua>_

- Instead we just take the defaults defined in the link above and overrides go in:
  * _~/.config/nvim/after/lsp/<lsp_filename.lua>_

Either way above best to match the filename nvim-lspconfig is using but you do you if you want to change it.  I wouldn't 🤷‍♂️

❗If you don't do this way and your overrides don't live in the 'after' folder, they will just get steamrolled is all.  

