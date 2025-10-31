local PSES_DIR = vim.fn.expand("~/.local/share/nvim/mason/packages/powershell-editor-services/PowerShellEditorServices")
local PSES_SCRIPT = PSES_DIR .. "/Start-EditorServices.ps1"
local SESSION_TEMP_PATH = vim.fn.expand("~/tmp/nvim_powershell_session")
vim.fn.mkdir(SESSION_TEMP_PATH, "p") -- Ensure the temporary directory exists

return {
    cmd = {
        "pwsh", "-NoLogo", "-NoProfile", "-File", PSES_SCRIPT,
        "-BundledModulesPath", PSES_DIR,
        "-LogPath", SESSION_TEMP_PATH .. "/logs.log",
        "-SessionDetailsPath", SESSION_TEMP_PATH .. "/session.json",
        "-FeatureFlags", "@()",
        "-AdditionalModules", "@()",
        "-HostName", "'Neovim'",
        "-HostProfileId", "'nvim'",
        "-HostVersion", "1.0.0",
        "-Stdio",
        "-LogLevel", "Normal", --[ValidateSet("Diagnostic", "Verbose", "Normal", "Warning", "Error")]
    },
    filetypes = {
        'ps1',
        'psd1',
        'psm1',
    },
    root_markers = {
        'psd1',
        'psm1',
        '.git',
    },
    settings = {
        powershell = {
            codeFormatter = "PSScriptFormatter",
            codeFormatting = {
                addWhitespaceAroundPipe = true,
                alignPropertyValuePairs = true,
                autoCorrectAliases = false,
                avoidSemicolonsAsLineTerminators = true,
                ignoreOneLineBlock = true,
                newLineAfterCloseBrace = false,
                newLineAfterOpenBrace = false,
                openBraceOnSameLine = true,
                pipelineIndentationStyle = 'NoIndentation',
                preset = "OTBS",
                trimWhitespaceAroundPipe = true,
                useConstantStrings = false,
                useCorrectCasing = true,
                whitespaceAfterSeparator = true,
                whitespaceAroundOperator = true,
                whitespaceAroundPipe = true,
                whitespaceBeforeOpenBrace = true,
                whitespaceBeforeOpenParen = true,
                whitespaceBetweenParameters = false,
                whitespaceInsideBrace = false,
            },
            --formatOnType = true,
        }
    }
}
