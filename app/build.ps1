$PSD1=$PSScriptRoot+'\GamutManifestTool.psd1'
if (Test-Path -Path $PSD1) {
    Remove-Item -Path $PSD1 -Confirm:$false -Force
}

$Description=@"
Build application manifests for Gamut by RePass Cloud and add applications to the growing library of software supported!

Using either PSCore or PowerShell, application manifests are like 'recipies' for applications installations and package management using Gamut for end-users.

"@

$FileList=@(
    'Public',
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

$Public=Get-ChildItem $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue
#$Private = Get-ChildItem $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue 
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

if ($Env:APPVEYOR_BUILD_NUMBER) {
    $CurrentBuild=$Env:APPVEYOR_BUILD_NUMBER
}

# Update the PS Scripts with the version and build
$OldVersionString='  Version:';
$NewVersionString="  Version:        2.1.36.{0}" -f $CurrentBuild
$LastUpdated='  Last Updated:';
$LatestUpdated="  Last Updated:   $((Get-Date).ToString('yyyy-MM-dd'))";
Get-ChildItem -Path "$Env:APPVEYOR_BUILD_FOLDER\public" -Filter "*.ps1" | ForEach-Object {
    $ManifestContent = Get-Content -Path $_.FullName -Raw;
    $ManifestContent = $ManifestContent -replace $OldVersionString,$NewVersionString;
    $ManifestContent = $ManifestContent -replace $LastUpdated,$LatestUpdated;
    Set-Content -Path $_.FullName -Value $ManifestContent -Force;
}
