if (-not (Get-Command -Name oh-my-posh -ErrorAction SilentlyContinue)) {
    if ($IsLinux) {
        'Installing oh-my-posh (Linux)...'
        sudo Invoke-WebRquest -Uri https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -OutFile /usr/local/bin/oh-my-posh && sudo chmod +x /usr/local/bin/oh-my-posh
    } elseif ($IsWindows) {
        'Installing oh-my-posh (Windows)...'
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
    }
}

if ($IsLinux) {
    $env:POSH_THEMES_PATH = "~/.poshthemes/"
}

if (-not (Test-Path -Path $env:POSH_THEMES_PATH)) {
    'Creating POSH_THEMES_PATH location...'
    New-Item -Path $env:POSH_THEMES_PATH -ItemType Directory -Force
}

$ProgressPreference = 'SilentlyContinue'
$gistUrl = 'https://gist.github.com'
$gistFiles = (Invoke-WebRequest -Uri "$gistUrl/ephos/ba04ce3b9ad12860cfbf4302438aa2a4").Links.Where({$_.outerHTML -like '*raw*'}).href

$currentTheme = $gistFiles | Where-Object {$_ -like '*bobbybologna*'}
$themeCode = ('{0}{1}' -f $gistUrl, $currentTheme)

$wc = [System.Net.WebClient]::new()
$hash = Get-FileHash -InputStream ($wc.OpenRead($themeCode))

if (-not (Test-Path -Path "$env:POSH_THEMES_PATH/bobbybologna.omp.json")) {
    'Downloading theme...'
    Invoke-WebRequest -Uri $themeCode -OutFile "$env:POSH_THEMES_PATH/bobbybologna.omp.json"
} elseif ((Get-FileHash -Path "$env:POSH_THEMES_PATH/bobbybologna.omp.json").Hash -ne $hash.hash) {
    'Theme out of date, grabbing latest version...'
    Invoke-WebRequest -Uri $themeCode -OutFile "$env:POSH_THEMES_PATH/bobbybologna.omp.json"
}

try {
    $currentProfile = $gistFiles | Where-Object {$_ -like '*pwshprofile*'}
    $profileCode = ('{0}{1}' -f $gistUrl, $currentProfile)
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString($profileCode)
} catch {
    Write-Warning -Message 'Could not connect to Github to pull profile code.'
    exit 1
}
$ProgressPreference = 'Continue'
