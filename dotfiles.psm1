Register-ArgumentCompleter -CommandName Sync-Dots -ParameterName MachineProfile -ScriptBlock {
    Get-Dots -ShowTracked | Select-Object -ExpandProperty machineProfile -Unique
}

function Initialize-Dots {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $false)]
        [string]$DotfileRepoPath = "$HOME/code/git/dotfiles"
    )

    # Validate the repository path
    if (-not (Test-Path -Path $DotfileRepoPath -PathType Container)) {
        Write-Error "The provided DotfileRepoPath '$DotfileRepoPath' is invalid or does not exist." -ErrorAction Stop
    } else {
        Write-Verbose -Message ('Dotfile repository exists at: {0}' -f $DotfileRepoPath)
    }

    # Define the path to the dots.json file
    $homeDirectory = $HOME
    $dotsFilePath = Join-Path -Path $homeDirectory -ChildPath "dots.json"

    # Check if the file already exists
    if (Test-Path -Path $dotsFilePath) {
        if ($PSCmdlet.ShouldProcess("dots.json at $dotsFilePath", "Re-create dots.json")) {
            Remove-Item -Path $dotsFilePath -Force
            Write-Warning -Message "Removed existing dots.json file."
        } else {
            Write-Warning -Message "dots.json already exists at $dotsFilePath. Initialization skipped."
        }
    }

    # Initialize the structure for dots.json
    $dotsJson = @{
        dotFileRepo  = $DotfileRepoPath
        trackedFiles = @()
        ignoreList   = @(".git", ".svn")
    }

    # Convert the structure to JSON and create the file
    $dotsJson | ConvertTo-Json -Depth 10 | Set-Content -Path $dotsFilePath -Encoding UTF8

    ("dots.json has been successfully initialized at: {0}") -f $dotsFilePath
}

function Get-Dots {
    [CmdletBinding()]
    param(
        # Show Tracked
        [Parameter()]
        [switch]
        $ShowTracked
    )

    # Define the path to the dots.json file
    $homeDirectory = $HOME
    $dotsFilePath = Join-Path -Path $homeDirectory -ChildPath "dots.json"

    # Ensure the dots.json file exists
    if (-not (Test-Path -Path $dotsFilePath)) {
        Write-Error "dots.json does not exist. Please run Initialize-Dots first." -ErrorAction Stop
    }

    # Output the contents of dots.json
    if ($PSBoundParameters.ContainsKey('ShowTracked')) {
        Get-Content -Path $dotsFilePath -Raw | ConvertFrom-Json | Select-Object -ExpandProperty trackedFiles
    } else {
        Get-Content -Path $dotsFilePath -Raw | ConvertFrom-Json 
    }
}

function Add-Dots {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$MachineProfile = "common"
    )

    # Define the path to the dots.json file
    $homeDirectory = $HOME
    $dotsFilePath = Join-Path -Path $homeDirectory -ChildPath "dots.json"

    # Ensure the dots.json file exists
    if (-not (Test-Path -Path $dotsFilePath)) {
        Write-Error "dots.json does not exist. Please run Initialize-Dots first." -ErrorAction Stop
    }

    # Load existing JSON data
    $dotsJson = Get-Content -Path $dotsFilePath -Raw | ConvertFrom-Json
    # Convert trackedFiles to a modifiable collection
    if ($dotsJson.trackedFiles) {
        $trackedFiles = [System.Collections.Generic.List[PSCustomObject]]$dotsJson.trackedFiles
    } else {
        $trackedFiles = [System.Collections.Generic.List[PSCustomObject]]::new()
    }

    # Retrieve the dotFileRepo path
    $dotFileRepo = $dotsJson.dotFileRepo
    if (-not (Test-Path -Path $dotFileRepo -PathType Container)) {
        Write-Error "The repository path '$dotFileRepo' specified in dots.json does not exist." -ErrorAction Stop
    }

    # Ensure the machineProfile directory exists
    $profileRepoPath = Join-Path -Path $dotFileRepo -ChildPath $MachineProfile
    if (-not (Test-Path -Path $profileRepoPath)) {
        ("Creating profile directory: {0}" -f $profileRepoPath)
        New-Item -Path $profileRepoPath -ItemType Directory | Out-Null
    }

    # Get ignore list
    $ignoreList = $dotsJson.ignoreList

    # Current date
    $currentDate = (Get-Date).ToString("o") # ISO 8601 format

    # Process a single file or directory
    if (Test-Path -Path $Path -PathType Leaf) {
        ### Single file logic ###
        $file = Get-Item -Path $Path -Force -ErrorAction Stop

        $relativePath = $file.FullName.split("$HOME").trim('/')[-1]
        $checksum = (Get-FileHash -Path $file -Algorithm SHA256).Hash
        #Destination path for copying the dotfile 
        $destinationPath = Join-Path -Path $profileRepoPath -ChildPath $relativePath

        # Check if the file is already tracked and copied
        $existingEntry = $trackedFiles | Where-Object {
            $_.filePath -eq $relativePath -and $_.machineProfile -eq $MachineProfile
        }

        if ($existingEntry -and (Test-Path -Path $destinationPath)) {
            Write-Warning "The file '$relativePath' is already tracked and copied for machine profile '$MachineProfile'."
        } else {
            $guid = (New-Guid).Guid
            # Copy file and add entry
            New-Item -Path $destinationPath -Force | Out-Null
            Copy-Item -Path $Path -Destination $destinationPath -Force
            $trackedFiles.Add([PSCustomObject]@{
                    fileName       = $file.Name
                    filePath       = $relativePath
                    sha256         = $checksum
                    id             = $guid
                    dateAdded      = $currentDate
                    dateModified   = $currentDate
                    machineProfile = $MachineProfile
                })
            ("Added new file to tracked files with profile '{0}': {1}" -f $MachineProfile, $relativePath)
        }
    } elseif (Test-Path -Path $Path -PathType Container) {
        ### Directory logic ###
        Get-ChildItem -Path $Path -Recurse -Exclude $ignoreList | ForEach-Object {
            if (-not $_.PSIsContainer) {
                $relativePath = $_.FullName.split("$HOME").trim('/')[-1]
                $checksum = (Get-FileHash -Path $_ -Algorithm SHA256).Hash
                $destinationPath = Join-Path -Path $profileRepoPath -ChildPath $relativePath

                # Check if the file is already tracked and copied
                $existingEntry = $trackedFiles | Where-Object {
                    $_.filePath -eq $relativePath -and $_.machineProfile -eq $MachineProfile
                }
                if ($existingEntry -and (Test-Path -Path $destinationPath)) {
                    Write-Warning "The file '$relativePath' is already tracked and copied for machine profile '$MachineProfile'."
                } else {
                    $guid = (New-Guid).Guid
                    # Copy file and add entry
                    New-Item -Path (Split-Path -Path $destinationPath -Parent) -ItemType Directory -Force | Out-Null
                    Copy-Item -Path $_ -Destination $destinationPath -Force
                    $trackedFiles.Add([PSCustomObject]@{
                            fileName       = $_.Name
                            filePath       = $relativePath
                            sha256         = $checksum
                            id             = $guid
                            dateAdded      = $currentDate
                            dateModified   = $currentDate
                            machineProfile = $MachineProfile
                        })
                    ("Added new file to tracked files with profile '{0}': {1}" -f $MachineProfile, $relativePath) 
                }
            }
        }
    } else {
        Write-Error "The path '$Path' is invalid or does not exist." -ErrorAction Stop
    }

    # Update the JSON data and save back to the file
    $dotsJson.trackedFiles = $trackedFiles
    $dotsJson | ConvertTo-Json -Depth 10 | Set-Content -Path $dotsFilePath -Encoding UTF8
}

function Sync-Dots {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [string]$MachineProfile,

        [Parameter()]
        [ValidateSet('Quiet', 'Minimal', 'Max')]
        [string]$InfoLevel = 'Minimal'
    )

    $dotsJson = Get-Dots 
    $trackedFiles = $dotsJson.trackedFiles | Where-Object {$_.machineProfile -eq 'common' -or $_.machineProfile -eq $MachineProfile}

    # Retrieve the dotFileRepo path
    $dotFileRepo = $dotsJson.dotFileRepo
    if (-not (Test-Path -Path $dotFileRepo -PathType Container)) {
        Write-Error "The repository path '$dotFileRepo' specified in dots.json does not exist." -ErrorAction Stop
    }

    foreach ($dotfile in $trackedFiles) {
        # Local file
        $localPath = Join-Path -Path $HOME -ChildPath $dotfile.filePath
        $localFile = Get-Item -Path $localPath -Force -ErrorAction Stop
        $localFileChecksum = (Get-FileHash -Path $localPath -Algorithm SHA256).Hash

        # Repo dotfile
        $repoPath = Join-Path -Path "$dotFileRepo" -ChildPath ("{0}/{1}" -f $dotfile.machineProfile, $dotfile.filePath)
        #$repoDotfile = Get-Item -Path $repoPath -Force -ErrorAction Stop

        # Check checksums
        if ($dotfile.sha256 -ne $localFileChecksum) {
            switch ($InfoLevel) {
                'Quiet' {
                    continue
                }
                'Minimal' {
                    "$($PSStyle.Formatting.Warning)[⚠️] Checksum mismatch for file: $($localFile.FullName)$($PSStyle.Reset)"
                }
                'Max' {
                    "$($PSStyle.Formatting.Warning)[⚠️] Checksum mismatch for file: $($localFile.FullName)`n`tExpect: $($dotfile.sha256) `n`tActual: $localFileChecksum $($PSStyle.Reset)"
                }
            } 

            if ($PSCmdlet.ShouldProcess("$($localFile.Name) at $localPath", "Copy file in $repoPath $($dotfile.filePath)")) {
                Copy-Item -Path $repoPath -Destination $localPath -Force
                # Update modify and checksum
                $dotfile.dateModified = (Get-Date).ToString("o")
                $dotfile.sha256 = (Get-FileHash -Path $localFile -Algorithm SHA256).Hash
            }

        } else {
            switch ($InfoLevel) {
                'Quiet' {
                    continue
                }
                'Minimal' {
                    "[✅] Checksum match for file: $($localFile.FullName)"
                }
                'Max' {
                    "[✅] Checksum match for file: $($localFile.FullName)`n`tExpect: $($dotfile.sha256) `n`tActual: $localFileChecksum"
                }
            } 
        }
    }

    #Update the JSON data and save back to the file
    $homeDirectory = $HOME
    $dotsFilePath = Join-Path -Path $homeDirectory -ChildPath "dots.json"
    $dotsJson.trackedFiles = $trackedFiles
    $dotsJson | ConvertTo-Json -Depth 10 | Set-Content -Path $dotsFilePath -Encoding UTF8
}


















































