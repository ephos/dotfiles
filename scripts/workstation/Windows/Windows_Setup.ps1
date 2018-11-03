function Test-Administrator
{
    [CmdletBinding()]
    param()
    $currentPrincipal = New-Object -TypeName Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)    
}


Write-Output -InputObject 'Setting PSGallery PSRepository to trusted...'
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Write-Output -InputObject 'Updating/Installing modules...'
Install-Module PowershellGet -Scope CurrentUser -Force
Install-Module posh-git, PesterVideoRecordingSettings

Write-Output -InputObject 'Updating help files...'
Update-Help -Force

switch ($PSVersionTable.Platform)
{
    'Windows'
    {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    }
    'Unix'
    {
        Set-PSReadLineOption -EditMode Windows
    }
    default
    {
        Write-Error -Message "Script does not contain options for $($PSVersionTable.Platform)." -ErrorAction Stop
    }
}

