-- DAP Keybinds
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
vim.keymap.set("n", "<F10>", ":lua require'dap'.step_over()<CR>")
vim.keymap.set("n", "<F11>", ":lua require'dap'.step_into()<CR>")
vim.keymap.set("n", "<F12>", ":lua require'dap'.step_out()<CR>")
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
vim.keymap.set("n", "<leader>lp", ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
vim.keymap.set("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>")

-- Debug Go Test
vim.keymap.set("n", "<leader>dt", ":lua require ('dap-go').debug_test()<CR>")

require("dap-go").setup()
require("dapui").setup()
require("nvim-dap-virtual-text").setup()

-- Listeners for starting Dap and DapUI automatically
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- DAP requires both an adapter and a configuration

-- PowerShell

local PSES_BUNDLE_PATH = vim.fn.expand("~/.local/share/nvim/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1")
local SESSION_TEMP_PATH = "/tmp/nvim_powershell_session"

dap.adapters.powershell = {
  type = 'executable',
  command = 'pwsh', -- Use 'powershell.exe' on Windows if not using PowerShell Core
  args = {'-NoLogo', '-NoProfile', '-Command', PSES_BUNDLE_PATH, '-BundledModulesPath', PSES_BUNDLE_PATH, '-LogPath', SESSION_TEMP_PATH .. "/logs.log", '-SessionDetailsPath', SESSION_TEMP_PATH .. "/session.json", '-FeatureFlags', '@()', '-AdditionalModules', '@()', '-HostName', 'nvim', '-HostProfileId', 'nvim', '-HostVersion', '1.0.0', '-Stdio', '-LogLevel', 'Normal'},
}

dap.configurations.ps1 = {
  {
    type = 'powershell',
    request = 'launch',
    name = "PowerShell Debug",
    script = '${file}', -- Debug the current file
    cwd = '${workspaceFolder}',
    -- Optional configurations:
    -- args = {'some', 'args'}, -- Arguments to the script
    -- env = {Variable = "value"}, -- Environment variables
    -- externalConsole = false, -- Use an external console
  }
}
