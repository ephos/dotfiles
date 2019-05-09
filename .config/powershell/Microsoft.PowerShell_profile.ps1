# TODO: Finish this.
#Set scripts directory.
if ($IsWindows) {
    $codePath = ('{0}\code\' -f $env:USERPROFILE)
}
else {
    $codePath = ('{0}/code/' -f $env:USERPROFILE)
}

if (Test-Path -Path $codePath -ErrorAction SilentlyContinue) {
    Set-Location -Path $codePath
}
else {
    Write-Warning -Message "No code directory found at $codePath."
}

#region PROMPT SETUP
############################

# Characters / Keys
$decoChar = [Char](0x00A7)
$escChar = [Char](0x1B)
$gitChar = [Char](0xE0A0)
$rightArrowFull = [Char](0xE0B0)
$rightArrowHalf = [Char](0xE0B1)

# Colors / Font Modifiers
$ansiReset = "$escChar[0m"
$ansiSlowBlink = "$escChar[5m"

# Decorator - RGB (Fg/Text 0,0,0) (Bg 70,167,252) 
# Computer Name - RGB(Fg/Text 255,255,255) (Bg 70,23,145)
# Directory - RGB(Fg/Text 0,0,0) (Bg 61,255,187)
# Git - RGB(Fg 183,220,255) (Bg 0,0,0)
$ansiColorBlack = "0;0;0"
$ansiColorWhite = "255;255;255"

$ansiColorPurple = "70;23;145"
$ansiColorGitOrange = "241;80;47"
$ansiColorBlue = "70;167;252"
$ansiColorLightPurple = "201;26;204" 

$ansiDecorator = "$escChar[38;2;$ansiColorBlack;48;2;$ansiColorBlue`m"
$ansiDecoratorToComputerNameTrans = "$escChar[38;2;$ansiColorBlue;48;2;$ansiColorPurple`m" 
$ansiComputerName = "$escChar[38;2;$ansiColorWhite;48;2;$ansiColorPurple`m"
$ansiComputerNameDirectoryTrans = "$escChar[38;2;$ansiColorPurple;48;2;$ansiColorLightPurple`m"
$ansiDirectory = "$escChar[38;2;$ansiColorBlack;48;2;$ansiColorLightPurple`m"
$ansiDirectoryEndPrompt = "$escChar[38;2;$ansiColorLightPurple`m"

$ansiDirectoryToGitTans = "$escChar[38;2;$ansiColorLightPurple;48;2;$ansiColorGitOrange`m"
$ansiGit = "$escChar[38;2;$ansiColorBlack;48;2;$ansiColorGitOrange`m"
$ansiGitEndPrompt = "$escChar[38;2;$ansiColorGitOrange`m"

function prompt {
    # Microsoft Docs ANSI ESC sequences (https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences)

    # Get current path parent and leaf.
    $currentDirectoryLeaf = Split-Path (Get-Location) -Leaf
    $currentDirectoryParent = Split-Path (Get-Location) -Parent

    # Determine platform and if Windows check for administrator token, if Unix check if root.
    if ($IsWindows) {
        $currentIdentity = New-Object -TypeName System.Security.Principal.WindowsPrincipal -ArgumentList @([System.Security.Principal.WindowsIdentity]::GetCurrent())
        $isAdminOrRoot = $currentIdentity.IsInRole([System.Security.Principal.WindowsBuiltInRole]"Administrator")
    }
    else {
        $isAdminOrRoot = (
            ((whoami) -eq 'root') -or
            ((groups) -split ' ' -contains 'root') # You could optionally add wheel if you want.
        )
    }

    # Determine platform and set the username color based on admin status.
    if ($IsWindows) {
        if ($isAdminOrRoot) {
            $currentUser = "$env:USERNAME [ADMIN]"
        }
        else {
            $currentUser = "$env:USERNAME [USER]"
        }
    }
    else {
        if ($isAdminOrRoot) {
            $currentUser = "$env:USER [ROOT]"
        }
        else {
            $currentUser = "$env:USER [USER]"
        }
    }

    # Prompt (Right Side, No left side in this case).  Create a list of scriptblocks.
    # While it does add a tiny bit of complexity, it makes prompt parts modular and swappable over strining Write-Host in a specific order.
    [System.Collections.Generic.List[ScriptBlock]]$promptPartsAll = @(
        { "$ansiDecorator"; "$decoChar"; "$ansiReset" }
        { "$ansiDecoratorToComputerNameTrans"; "$rightArrowFull"; "$ansiReset" }
        { "$ansiComputerName"; "$([System.Net.Dns]::GetHostName())"; "$ansiReset" }
        { "$ansiComputerNameDirectoryTrans"; "$rightArrowFull"; "$ansiReset" }
        { "$ansiDirectory"; "$currentDirectoryLeaf"; "$ansiReset" }
    )

    # Git prompt no dependencies.
    if ((git status -b) -match 'On branch*') {
        $gitBranch = (git symbolic-ref --short -q HEAD)
        $gitStatusShort = (git status --short --branch)

        [int]$gitAhead = 0 
        [int]$gitBehind = 0
        [int]$gitUnTracked = 0
        [int]$gitUnStagedMod = 0
        [int]$gitStagedAdd =0 
        [int]$gitStagedMod = 0
        [int]$gitStagedRen = 0
        [int]$gitStagedDel = 0

        foreach ($line in $gitStatusShort) {
            # Minimal testing seemed to show that utilizing the [Regex]::Match() static method and just using PowerShells -match operator were comperable in speed.
            switch ($line) {
        #         # Branch - Ahead/Behind
        #         { $line -match '#{2} {1}' } {
        #             [Int]$gitAhead = [Regex]::Match($line, '(?<=ahead\s)\d+').Value
        #             [Int]$gitBehind = [Regex]::Match($line, '(?<=behind\s)\d+').Value
        #         }

                { $line -match '\?{2} {1}' } { $gitUnTracked++ } #UnTracked Files
                { $line -match ' {1}M{1} {1}' } { $gitUnStagedMod++ } # UnStaged Files Modified
                { $line -match 'A{1} {2}' } { $gitStagedAdd++ } # Staged Files Added
                { $line -match 'M{1} {2}' } { $gitStagedMod++ } # Staged Files Modified
                { $line -match 'R{1} {2}' } { $gitStagedRen++ } # Staged Files Renamed
                { $line -match 'D{1} {2}' } { $gitStagedDel++ } # Staged Files Deleted
                { $line -match 'A{1}M{1} {1}' } { $gitUnStagedMod++; $gitStagedAdd++ } # File Staged and Unstaged Modified

                #Default { Write-Warning -Message "Couldn't match a git status line, something needs to be fixed." }
            }
        }

        $unstagedorTrackedFiles = ($gitUnTracked + $gitUnStagedMod)
        $stagedFiles = ($gitStagedAdd + $gitStagedMod + $gitStagedRen + $gitStagedDel)

        [System.Collections.Generic.List[ScriptBlock]]$promptPartsGit = @(
            { "$ansiDirectoryToGitTans"; "$rightArrowFull"; "$ansiReset" }
            { "$ansiGit"; "$gitChar"; "$ansiReset"}
            { "$ansiGit"; " $gitBranch"; "$ansiReset"}
            #{ "$ansiGit"; " |"; "$ansiReset"}
            {
                if ($unstagedorTrackedFiles -gt 0) { "$ansiGit"; " |"; "$ansiReset"}
            }
            {
                if ($unstagedorTrackedFiles -gt 0) {
                    if ($gitUnTracked -gt 0) {"$ansiGit"; " ?$gitUnTracked"; "$ansiReset"}
                    if ($gitUnStagedMod -gt 0) {"$ansiGit"; " ~$gitUnStagedMod"; "$ansiReset"}
                }
            }
            #{ "$ansiGit"; " |"; "$ansiReset"}
            {
                if ($stagedFiles -gt 0) { "$ansiGit"; " |"; "$ansiReset"}
            }
            {
                if ($stagedFiles -gt 0) {
                    if ($gitStagedAdd -gt 0) {"$ansiGit"; " +$gitStagedAdd"; "$ansiReset"}
                    if ($gitStagedMod -gt 0) {"$ansiGit"; " ~$gitStagedMod"; "$ansiReset"}
                    if ($gitStagedRen -gt 0) {"$ansiGit"; " r$gitStagedRen"; "$ansiReset"}
                    if ($gitStagedDel -gt 0) {"$ansiGit"; " -$gitStagedDel"; "$ansiReset"}
                }
            }
            { "$ansiGitEndPrompt"; "$rightArrowFull"; "$ansiReset" }
        )

        $prompt = -join @($promptPartsAll + $promptPartsGit).Invoke()

        Get-Variable -Name 'gitStage*', 'gitUnStage*' | Clear-Variable -Force -ErrorAction SilentlyContinue
    } else {
        [System.Collections.Generic.List[ScriptBlock]]$promptPartsNoGit = @(
            { "$ansiDirectoryEndPrompt"; "$rightArrowFull"; "$ansiReset" }
        )
        $prompt = -join ($promptPartsAll + $promptPartsNoGit).Invoke()        
    }

    # Setup window title.
    $shell = $Host.Ui.RawUI
    $shell.WindowTitle = "$currentDirectoryParent | $currentUser | $($PSVersionTable.GitCommitId)"

    #Write out the prompt
    $prompt
}


############################
#endregion

#Go Stuff
############################
#Set go workspace.
if (Get-Command -Name go) {
    if (-not (Test-Path -Path env:GOPATH)) {
        Write-Output -InputObject 'GOPATH is not setup, creating directory structure now.'
        New-Item -ItemType Directory -Path $env:GOPATH
        New-Item -ItemType Directory -Path $env:GOPATH\bin\
        New-Item -ItemType Directory -Path $env:GOPATH\src\
        New-Item -ItemType Directory -Path $env:GOPATH\pkg\
    }
}
else {
    Write-Warning -Message "Go Language not installed, skipping."
}
############################
#endregion

#region Custom Alias'
############################

New-Alias -Name ih -Value Invoke-History -Force
New-Alias -Name gh -Value Get-History -Force

function Set-PathToGoWorkspace { Set-Location -Path "$($env:GOPATH)" }
New-Alias -Name gogo -Value Set-PathToGoWorkspace -Force
function Set-PathToLocalGit {Set-Location -Path "$($env:USERPROFILE)\code\git"}
New-Alias -Name gogit -Value Set-PathToLocalGit -Force
function Set-PathToScripts {Set-Location -Path "$($env:GOPATH)"}
New-Alias -Name goscripts -Value Set-PathToScripts -Force
New-Alias -Name gocode -Value Set-PathToScripts -Force
New-Alias -Name gohome -Value Set-PathToScripts -Force

if ($IsWindows) {
    function Copy-CorpCred {(Get-PasswordstateCredential -Domain corp -Name pleauro).GetNetworkCredential().Password | clip.exe}
    New-Alias -Name qwe -Value Copy-CorpCred -Force
    
    function Get-AdminCredential {Get-PasswordstateCredential -Domain corp -Name pleauro}
    New-Alias -Name ga -Value Get-AdminCredential -Force
    
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