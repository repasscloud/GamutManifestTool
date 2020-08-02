# Remove if existing PSD1 file
$PSD1=$PSScriptRoot+'\app\GamutManifestTool.psd1'
Write-Output $PSD1
if (Test-Path -Path $PSD1) {
    Remove-Item -Path $PSD1 -Confirm:$false -Force
}

# Copy required files to 'App' Directory
'LICENSE','README.md','CHANGELOG.md' | ForEach-Object {
    $FileName=$_;
    Copy-Item -Path C:\Projects\GamutManifestTool\$FileName -Destination C:\Projects\GamutManifestTool\app\ -Force -Confirm:$false
}

$Description=@"
Gamut Manifest Tools helps you build, test, and manage application manifests for Gamut by Repass Cloud.

Gamut Manifest Tools include:
  - New-GamutManifest: Build a manifest for an application
  - Test-GamutManifest: Tests existing manifests for validity before deployment

Leveraging PSCore or PowerShell, application manifests are like 'recipies' for applications installations and package management using Gamut for end-users and can be built on either Windows, MacOS or Linux.
"@

$FileList=@(
    'Public',
    'Private',
    '.\LICENSE',
    '.\README.md',
    '.\GamutManifestTool.psm1',
    '.\CHANGELOG.md'
)

$Author='Danijel-James Wynyard'
$CompanyName='RePass Cloud Pty Ltd'
$Copyright='Copyright '+[char]0x00A9+' 2020 RePass Cloud Pty Ltd'

$Tags=@('apt','gamut','software','library','apk','nuget','app','custom','soe','install','installers','win','windows','winapp','aptitude')
$ProjectUri='https://github.com/repasscloud/GamutManifestTool'
$LicenseUri='https://github.com/repasscloud/GamutManifestTool/blob/master/LICENSE'
$ReleaseNotes=@"
Initial release to PSModule.
"@

$Public=Get-ChildItem -Path ..\..\app\Public -Filter "*.ps1" -ErrorAction SilentlyContinue
[Array]$FunctionsToExport=$($Public | Select-Object -ExpandProperty BaseName)

$HelpInfoURI='https://raw.githubusercontent.com/repasscloud/GamutManifestTool/master/README.md'

$ModuleVersion=$Env:APPVEYOR_BUILD_VERSION

New-ModuleManifest -Path $PSD1 `
  -Author $Author `
  -CompanyName $CompanyName `
  -Copyright $Copyright `
  -RootModule 'GamutManifestTool.psm1' `
  -ModuleVersion $ModuleVersion `
  -Description $Description `
  -PowerShellVersion '5.1' `
  -ProcessorArchitecture None `
  -FileList $FileList `
  -Tags $Tags `
  -ProjectUri $ProjectUri `
  -LicenseUri $LicenseUri `
  -ReleaseNotes $ReleaseNotes `
  -FunctionsToExport $FunctionsToExport `
  -HelpInfoUri $HelpInfoURI

# Update the PS Scripts with the version and build
$OldVersionString='Version:';
$NewVersionString="Version:        {0}" -f $Env:APPVEYOR_BUILD_VERSION
# AppVeyor only uses this script, on Github it will run with a different build script
$LastUpdated='  Last Updated:';
$LatestUpdated="  Last Updated:   $((Get-Date).ToString('yyyy-MM-dd'))";
Get-ChildItem -Path "$Env:APPVEYOR_BUILD_FOLDER\app\public" -Filter "*.ps1" | ForEach-Object {
    $ManifestContent = Get-Content -Path $_.FullName -Raw;
    $ManifestContent = $ManifestContent -replace $OldVersionString,$NewVersionString;
    $ManifestContent = $ManifestContent -replace $LastUpdated,$LatestUpdated;
    Set-Content -Path $_.FullName -Value $ManifestContent -Force;
}
Get-ChildItem -Path "$Env:APPVEYOR_BUILD_FOLDER\app\private" -Filter "*.ps1" | ForEach-Object {
  $ManifestContent = Get-Content -Path $_.FullName -Raw;
  $ManifestContent = $ManifestContent -replace $OldVersionString,$NewVersionString;
  $ManifestContent = $ManifestContent -replace $LastUpdated,$LatestUpdated;
  Set-Content -Path $_.FullName -Value $ManifestContent -Force;
}