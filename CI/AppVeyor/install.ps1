param ($fullPath)
#$fullPath = 'C:\Program Files\WindowsPowerShell\Modules\GamutManifestTool'
if (-not $fullPath) {
    $fullpath = $env:PSModulePath -split ":(?!\\)|;|," |
        Where-Object {$_ -notlike ([System.Environment]::GetFolderPath("UserProfile")+"*") -and $_ -notlike "$pshome*"} |
            Select-Object -First 1
            $fullPath = Join-Path $fullPath -ChildPath "GamutManifestTool"
}
$srcPath = $Env:APPVEYOR_BUILD_FOLDER + '\app'
Push-location $PSScriptRoot
robocopy $srcPath $fullPath /MIR
Pop-Location
Write-Output "Install path is ~> ${fullPath}"