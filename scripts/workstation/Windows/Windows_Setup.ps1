# Important Variables
$vsCodeExtensionFilePath = '..\vscodextensions.json'
$vsCodeSettingsFilePath = '.\VSCode\settings.json'
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

# Get Code
#Invoke-WebRequest -Uri 'https://github.com/ephos/dotfiles/archive/master.zip' -OutFile "$env:USERPROFILE\Desktop\dotfiles.zip"
#Expand-Archive -Path "$env:USERPROFILE\Desktop\dotfiles.zip" -DestinationPath "$env:USERPROFILE\Desktop\dotfiles\" -Force

# Setup
if (Test-Administrator)
{
    Write-OutputColor -Color DarkCyan -Message '[O] Installing Chocolatey...'
    powershell.exe -Command {
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    Write-OutputColor -Color DarkCyan -Message '[O] Installing Chocolatey Applications...'
    powershell.exe -Command {
        cinst.exe googlechrome vscode 7zip.install git.install greenshot golang dep putty.install nodejs.install vlc openssh sysinternals winscp.install ruby cmake.install python3 dotnetcore vagrant packer terraform vault Vim-Tux.install neovim etcher --confirm
    }

    Write-OutputColor -Color DarkCyan -Message '[O] Refreshing environment variables post install...'
    RefreshEnv.cmd
}
else
{
    Write-Warning -Message 'Administrator token missing, skipping Chocolatey steps!'
}

Write-OutputColor -Color DarkCyan -Message '[O] Installing VSCode Extensions...'
if (Test-Path -Path $vsCodeExtensionFilePath)
{
    if (code --version)
    {
        Write-OutputColor -Color DarkCyan -Message '[O] Copying VSCode Settings...'
        Copy-Item -Path $vsCodeSettingsFilePath -Destination "$env:USERPROFILE\AppData\Roaming\Code\User\" -Force

        $ext = Get-Content -Path $vsCodeExtensionFilePath | ConvertFrom-Json
        foreach ($e in $ext)
        {
            & code --install-extension $e --user-data-dir $env:USERPROFILE\AppData\Roaming\Code\User\
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

Write-OutputColor -Color DarkCyan -Message '[O] Setting PSGallery PSRepository to trusted...'
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Write-OutputColor -Color DarkCyan -Message '[O] Updating/Installing modules...'
Install-Module PowershellGet -Scope CurrentUser -Force -Confirm:$false
Remove-Module -Name PowerShellGet, PackageManagement -Force
Install-Module posh-git, Pester, PSReadLine -Scope CurrentUser -Force -Confirm:$false

if (Test-Administrator)
{
    Write-OutputColor -Color DarkCyan -Message '[O] Updating help files...'
    Update-Help -Force
}
else
{
    Write-Warning -Message 'Administrator token missing, skipping PowerShell update help step!'
}

if (Test-Administrator)
{
    Write-OutputColor -Color DarkCyan -Message '[O] Enabling Windows Subsystem for Linux...'
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    Invoke-WebRequest -Uri 'https://aka.ms/wsl-ubuntu-1804' -OutFile Ubuntu.appx -UseBasicParsing
    Add-AppxPackage -Path '.\Ubuntu.appx' # You can also rename appx to zip and run the exe directly.

}
else
{
    Write-Warning -Message 'Administrator token missing, skipping Windows Subsystem for Linux install step!'
}
