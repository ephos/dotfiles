$ProgressPreference = 'SilentlyContinue'
$gistUrl = 'https://gist.github.com'
try {
    $currentProfile = (Invoke-WebRequest -Uri "$gistUrl/ephos/ba04ce3b9ad12860cfbf4302438aa2a4").Links.Where({$_.outerHTML -like '*raw*'}).href
    $currentProfile = $currentProfile | Where-Object {$_ -like '*profile2*'}
    $profileCode = ('{0}{1}' -f $gistUrl, $currentProfile)
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString($profileCode)
} catch {
    Write-Warning -Message 'Could not connect to Gitub to pull profile code.'
    exit 1
}
$ProgressPreference = 'Continue'