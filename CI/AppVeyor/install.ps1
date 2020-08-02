param ($fullPath)
#$fullPath = 'C:\Program Files\WindowsPowerShell\Modules\GamutManifestTool'
if (-not $fullPath) {
    $fullpath = $env:PSModulePath -split ":(?!\\)|;|," |
        Where-Object {$_ -notlike ([System.Environment]::GetFolderPath("UserProfile")+"*") -and $_ -notlike "$pshome*"} |
            Select-Object -First 1
            $fullPath = Join-Path $fullPath -ChildPath "GamutManifestTool"
}
Push-location $PSScriptRoot
robocopy C:\Projects\GamutManifestTool\app $fullPath /MIR
Pop-Location