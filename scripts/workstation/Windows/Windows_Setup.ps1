# Important Variables
$vsCodeExtensionFilePath = '..\vscodextensions.json'
$conEmuSettingsFilePath = '.\ConEmu\ConEmu.xml'

# Private Functions
function Test-Administrator
{
    [CmdletBinding()]
    param()
    $currentPrincipal = New-Object -TypeName Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Write-OutputColor
{
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$Message,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('Black', 'Blue', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGray', 'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Gray', 'Green', 'Magenta', 'Red', 'White', 'Yellow')]$Color
    )
    process
    {
        $originalForeGroudColor = $host.ui.RawUI.ForegroundColor
        $host.ui.RawUI.ForegroundColor = $Color
        Write-Output -InputObject $Message
        $host.ui.RawUI.ForegroundColor = $originalForeGroudColor
    }
}

if (Test-Administrator)
{
    Write-OutputColor -Color DarkCyan -Message '[ᴑ] Installing Chocolatey...'
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    Write-OutputColor -Color DarkCyan -Message '[ᴑ] Installing Chocolatey Applications...'
    cinst.exe googlechrome vscode 7zip.install git.install greenshot golang dep putty.install nodejs.install vlc openssh sysinternals winscp.install ruby cmake.install python3 dotnetcore vagrant packer terraform vault Vim-Tux.install neovim etcher --confirm

}
else
{
    Write-Warning -Message 'Administrator token missing, skipping Chocolatey steps!'
}

Write-OutputColor -Color DarkCyan -Message '[ᴑ] Installing VSCode Extensions...'
if (Test-Path -Path $vsCodeExtensionFilePath)
{
    if (code --version)
    {
        $ext = Get-Content -Path $vsCodeExtensionFilePath | ConvertFrom-Json
        foreach ($e in $ext)
        {
            & code --install-extension $e
        }
    }
    else
    {
        Write-Warning -Message 'VSCode install issue!'
    }
}
else
{
    Write-Warning -Message 'VSCode extensions JSON file missing from repo, skipping!'
}

Write-OutputColor -Color DarkCyan -Message '[ᴑ] Setting PSGallery PSRepository to trusted...'
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Write-OutputColor -Color DarkCyan -Message '[ᴑ] Updating/Installing modules...'
Install-Module PowershellGet -Scope CurrentUser -Force
Install-Module posh-git, Pester, PSReadLine -Scope CurrentUser -Force

if (Test-Administrator)
{
    Write-OutputColor -Color DarkCyan -Message '[ᴑ] Updating help files...'
    Update-Help -Force
}
else
{
    Write-Warning -Message 'Administrator token missing, skipping PowerShell update help step!'
}

if (Test-Administrator)
{
    Write-OutputColor -Color DarkCyan -Message '[ᴑ] Enabling Windows Subsystem for Linux...'
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

}
else
{
    Write-Warning -Message 'Administrator token missing, skipping Windows Subsystem for Linux install step!'
}
