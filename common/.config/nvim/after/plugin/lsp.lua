-- List of LSP configs: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- Need this to bridge the lsp and cmd
local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.opt.completeopt = {'menuone', 'noselect', 'noselect'}

-- Auto Format with LSP, no-op if non found
vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]

-- Who but WB Mason to install our LSPs?
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

-- Make sure that nvim LSP client can lazy load these suckers
require("mason-lspconfig").setup {
    ensure_installed = { "lua_ls", "powershell_es", "pyright", "gopls" },
}

local lspkind = require("lspkind")

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", {fg ="#6CC644"})

-- Remapping some keys for CMP and making it look -~Fancy~-
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup {
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = {
        ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
        --['Tab'] = cmp.mapping.confirm({ select = true}),
        ['<C-l>'] = cmp.mapping.confirm({ select = true }),
        ['CR'] = cmp.mapping.complete(),
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp', group_index = 1 },
        { name = 'luasnip', group_index = 1 },
        { name = 'buffer', group_index = 1  },
        { name = 'path', group_index = 1   },
        { name = 'copilot', group_index = 4 },
        { name = 'nvim_lua', group_index = 2 },
    }),
    formatting = {
        format = lspkind.cmp_format({
          mode = 'text_symbol',
          symbol_map = {
            Copilot = ""
          },
          menu = ({
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              luasnip = "[LuaSnip]",
              path = "[Path]",
              copilot = "[Copilot]"
          }),
          maxwidth = 50,
          ellipsis_char = '...',
          -- The function below will be called before any actual modifications from lspkind
          -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
          before = function (entry, vim_item)
            return vim_item
          end
        })
    },
    window = {
        completion = {
            border = 'rounded',
        },
        documentation = {
            border = 'rounded'
        }
    }
}

-- Getting nice inline errors with Trouble to tell me how bad I am
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = true })

-- Set global key binds for the LSP for all the languages, no need to re-define N times. 
local on_attach = function(client, bufnr)

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    --Enable completion
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "<leader>gn", vim.diagnostic.goto_next, bufopts)
    vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format {async = true } end, bufopts)
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, bufopts)

end

local lspconfig = require('lspconfig')
local lsp_defaults = lspconfig.util.default_config

--------------------------------------------------------------------
-- Go
require('lspconfig').gopls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
}

--------------------------------------------------------------------
--Rust
require('lspconfig').rust_analyzer.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    settings = {
        ["rust-analyzer"] = {
            cargo = {
              extraEnv = { CARGO_PROFILE_RUST_ANALYZER_INHERITS = 'dev', },
              extraArgs = { "--profile", "rust-analyzer", },
            },
        },
    },
}

--------------------------------------------------------------------
--Godot/GDScript

-- Local vars for Godot
local port = os.getenv('GDScript_Port') or '6005'
local cmd = vim.lsp.rpc.connect('127.0.0.1', port)
local pipe = '/tmp/godot.pipe' -- I use /tmp/godot.pipe
-- This is hacky AF but was the only easy way I could get the LSP to attach to the right buffer
-- This makes it so I can run 'nvim .' and then use telescope and nvimtree still
_G.RestartGDScriptLSP = function()
  -- Stop existing GDScript LSP client(s)
  for _, client in ipairs(vim.lsp.buf_get_clients()) do
    if client.name == 'gdscript' then
      client.stop()
    end
  end
    require('lspconfig').gdscript.setup {

        name = 'Godot',
        cmd = cmd,
        root_dir = function(fname)
            local project_files = { 'project.godot', '.git' }
            return vim.fn.finddir(table.concat(project_files, ";"), fname .. ';')
        end,
        on_attach = function(client, bufnr)
            vim.api.nvim_command('echo serverstart("' .. pipe .. '")')
            print("LSP attached to buffer:", bufnr)
            --local opts = { noremap=true, silent=true }
            --vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
            vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", {noremap = true, silent = true, buffer=bufnr})
            vim.keymap.set("n", vim"gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {noremap = true, silent = true, buffer=bufnr})
            vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", {noremap = true, silent = true, buffer=bufnr})
            vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", {noremap = true, silent = true, buffer=bufnr})
        end,

        docs = {
            description = [[https://github.com/godotengine/godot

    Language server for GDScript, used by Godot Engine.
    ]],
        },

    }
end

vim.cmd [[
  autocmd BufEnter *.gd lua RestartGDScriptLSP()
]]

--[[
require 'lspconfig'.gdscript.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "gd", "gdscript", "gdscript3" },
}
]]--

--------------------------------------------------------------------
--Terraform
require('lspconfig').terraformls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    settings = {
        terraform = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
}

--------------------------------------------------------------------
--Marksman
require('lspconfig').marksman.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    settings = {
        marksman = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
}

--------------------------------------------------------------------
--PowerShell
local PSES_BUNDLE_PATH = vim.fn.expand("~/.local/share/nvim/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1")
local SESSION_TEMP_PATH = "/tmp/nvim_powershell_session"
vim.fn.mkdir(SESSION_TEMP_PATH, "p") --Ensure the temporary directory exists
require('lspconfig').powershell_es.setup {
    --[[
    I didn't end up needing this but I used to before a change an I am afraid I may need it again someday.
    Bundle path points to where Mason extracts PSES
    The following "vim.fn.stdpath("data")" -> "~/.local/share/nvim/", see :h stdpath for details.
    --bundle_path = (vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/PowerShellEditorServices"),
    ]]--
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    cmd = { "pwsh", "-NoLogo", "-NoProfile", "-Command", PSES_BUNDLE_PATH .. " -BundledModulesPath " .. PSES_BUNDLE_PATH .. " -LogPath " .. SESSION_TEMP_PATH .. "/logs.log -SessionDetailsPath " .. SESSION_TEMP_PATH .. "/session.json -FeatureFlags @() -AdditionalModules @() -HostName 'My Client' -HostProfileId 'myclient' -HostVersion 1.0.0 -Stdio -LogLevel Normal" },
    filetypes = { "ps1", "psm1", "psd1" },
    single_file_support = true,
    settings = {
        powershell = {
            codeFormatting = {
                preset = 'OTBS',

                AddWhitespaceAroundPipe = true,
                AutoCorrectAliases = true,
                AvoidSemicolonsAsLineTerminators = true,
                UseConstantStrings = false,
                OpenBraceOnSameLine = true,
                NewLineAfterOpenBrace = true,
                NewLineAfterCloseBrace = false,
                TrimWhitespaceAroundPipe = true,
                WhitespaceBeforeOpenBrace = true,
                WhitespaceBeforeOpenParen = true,
                WhitespaceAroundOperator = true,
                --WhitespaceAfterSeparator = true,
                WhitespaceBetweenParameters = false,
                WhitespaceInsideBrace = false,
                IgnoreOneLineBlock = true,
                AlignPropertyValuePairs = true,
                UseCorrectCasing = true,
            },
            formatOnType = true,
        }
    }
}

--------------------------------------------------------------------
--Python
--local PYRIGHT_PATH = vim.fn.expand("~/.local/share/nvim/mason/packages/pyright/node_modules/pyright/dist/pyright-langserver.js")
require('lspconfig').pyright.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    --cmd = { "node", PYRIGHT_PATH, "--stdio" },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "basic",
                stubPath = vim.fn.expand("~/.cache/nvim/lspconfig/pyright-stubs")
            }
        }
    }
}

--------------------------------------------------------------------
--Yaml
require 'lspconfig'.yamlls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    settings = {
        yaml = {
            keyOrdering = false,
            schemas = {
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose.yml",
                ["https://raw.githubusercontent.com/projectatomic/registries/master/registries.schema.json"] = "registries.yml"
            }
        }
    }
}

--------------------------------------------------------------------
--Lua
require('lspconfig').lua_ls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim', "on_attch", "flags" }
            }
        }
    }
}

--------------------------------------------------------------------
--C#
require 'lspconfig'.omnisharp.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    filetypes = { "cs", "csharp" },
}

--------------------------------------------------------------------
--Exlixir
local path_to_elixirls = vim.fn.expand("~/.cache/nvim/lspconfig/elixirls/elixir-ls/release/language_server.sh")
require 'lspconfig'.elixirls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    cmd = { path_to_elixirls },
    filetypes = { "elixir", "eelixir" },
    settings = {
        elixirLS = {
            dialyzerEnabled = false,
            fetchDeps = false
        }
    }
}
