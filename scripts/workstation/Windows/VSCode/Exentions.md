# VS Code Extensions

Export List of Installed Extensions.  This code can generate the JSON list which is used by the install scripts.

```powershell
# Get current extensions
$extensions = Get-ChildItem -Path "$env:USERPROFILE\.vscode\extensions\" | Select-Object -ExpandProperty Name

# Instantiate List
$extensionList = [System.Collections.Generic.List[string]]::new()
foreach ($e in $extensions)
{
    # Regex to scrub version
    $extensionList.Add($e -replace ("-[0-9].*\w+", ''))
}
# Serialize to JSON
$extensionsSerialized = $extensionList | Select-Object -Unique | ConvertTo-Json
$extensionsSerialized
```