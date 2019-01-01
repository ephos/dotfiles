#Set scripts directory.
switch ($PSVersionTable.Platform)
{
    'Windows'
    {
        ($codePath = '{0}\code\' -f $env:USERPROFILE)
    }
    'Unix'
    {
        ($codePath = '{0}/code/' -f $env:USERPROFILE)
    }
}

if (Test-Path -Path $codePath)
{
    Set-Location -Path $codePath
}
else
{
    Write-Warning -Message "No code directory found at $codePath."
}

#region PROMPT SETUP
############################
function prompt {

    # $currentIdentity = New-Object -TypeName System.Security.Principal.WindowsPrincipal -ArgumentList @([System.Security.Principal.WindowsIdentity]::GetCurrent())
    # $isAdmin = $currentIdentity.IsInRole([System.Security.Principal.WindowsBuiltInRole]"Administrator")

    $currentDirectoryLeaf = Split-Path (Get-Location) -Leaf
    $currentDirectoryParent = Split-Path (Get-Location) -Parent

    $consoleDelimiter = [ConsoleColor]::Cyan

    if ($PSVersionTable.Platform -eq 'Windows')
    {
        if ($isAdmin)
        {
            $consoleHost = [ConsoleColor]::Red
            $currentUser = "$env:USERNAME[ADMIN]"
        }
        else
        {
            $consoleHost = [ConsoleColor]::Green
            $currentUser = "$env:USERNAME[STANDARD]"
        }
    }
    else
    {
        $consoleHost = [ConsoleColor]::Blue
        $currentUser = "$env:USER"
    }

    $consoleLocation = [ConsoleColor]::White
    Write-Host "$([char]0x0A7) " -NoNewline -ForegroundColor $consoleLocation
    Write-Host ([System.Net.Dns]::GetHostName()) -NoNewline -ForegroundColor $consoleHost

    Write-Host ' [' -NoNewline -ForegroundColor $consoleDelimiter
    Write-Host ($currentDirectoryLeaf) -NoNewline -ForegroundColor $consoleLocation
    Write-Host '] ' -NoNewline -ForegroundColor $consoleDelimiter

    $shell = $Host.Ui.RawUI
    $shell.WindowTitle = "$currentDirectoryParent | $currentUser | $($PSVersionTable.GitCommitId)"

    if ($DefaultVIServers)
    {
        $viServer = $DefaultVIServers.Name -join ','
        $shell.WindowTitle = "$currentDirectoryParent | $currentUser | $viServer | $($PSVersionTable.GitCommitId)"
    }

    if (Get-Module -Name posh-git -ListAvailable)
    {
        Write-VcsStatus
    }
    else
    {
        Write-Warning -Message 'No posh-git module found, install with "Install-Module -Name posh-git"'
    }
}

    if (Get-Module -Name posh-git)
    {
        Start-SshAgent -Quiet
    }
############################
#endregion

#Go Stuff
############################
#Set scripts directory.
if ($PSVersionTable.Platform -eq 'Windows')
{
    if (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.Publisher -eq 'https://golang.org'})
    {
        Set-Item -Path env:GOPATH -Value "$env:USERPROFILE\Desktop\code\goworkspace\"
        if (-not (Test-Path -Path env:GOPATH))
        {
        Write-Output -InputObject 'GOPATH is not setup, creating directory structure now.'
            New-Item -ItemType Directory -Path $env:GOPATH
            New-Item -ItemType Directory -Path $env:GOPATH\bin\
            New-Item -ItemType Directory -Path $env:GOPATH\src\
            New-Item -ItemType Directory -Path $env:GOPATH\pkg\
        }
    }
    else
    {
        Write-Warning -Message "Go Language not installed, skipping."
    }
}
############################
#endregion

#region Custom Alias'
############################

New-Alias -Name ih -Value Invoke-History -Force
New-Alias -Name gh -Value Get-History -Force

function Set-PathToScripts {Set-Location -Path "$($env:GOPATH)"}
New-Alias -Name gogo -Value Set-PathToScripts -Force

if ($PSVersionTable.Platform -eq 'Windows')
{
    function Set-PathToLocalGit {Set-Location -Path "$($env:USERPROFILE)\Desktop\code\git"}
    New-Alias -Name gogit -Value Set-PathToLocalGit -Force

    if (Test-Path -Path 'C:\Program Files\OpenSSH\ssh.exe')
    {
        New-Alias -Name ssh -Value 'C:\Program Files\OpenSSH\ssh.exe' -Force
    }

    if (Test-Path -Path 'C:\Program Files (x86)\Vim\vim80\vim.exe')
    {
        New-Alias -Name vim -Value 'C:\Program Files (x86)\Vim\vim80\vim.exe' -Force
    }
}
############################
#endregion
