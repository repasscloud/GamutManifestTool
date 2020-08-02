param ($fullPath)
if (-not $fullPath) {
    $fullpath = $env:PSModulePath -split ":(?!\\)|;|," |
        Where-Object {$_ -notlike ([System.Environment]::GetFolderPath("UserProfile")+"*") -and $_ -notlike "$pshome*"} |
            Select-Object -First 1
            $fullPath = Join-Path $fullPath -ChildPath $Env:APPVEYOR_PROJECT_NAME
}
$srcPath = $Env:APPVEYOR_BUILD_FOLDER + '\app'
Push-location $PSScriptRoot
robocopy $srcPath $fullPath /MIR
Pop-Location