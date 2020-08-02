# Install required modules
'Get.URLStatusCode','GetRedirectedUrl','PSWriteColor' | ForEach-Object {
    $m = $_;
    Write-Output "Installing Module -> ${m}";
    Install-Module -Name $m -Force;
}

# Import required modules
'Get.URLStatusCode','GetRedirectedUrl','PSWriteColor' | ForEach-Object {
    $m = $_;
    Write-Output "Importing Module -> ${m}";
    Import-Module -Name $m -Force;
}

# Import current module
Write-Output "Import Module -> GamutManifestTool"

# Create new manifest test
Write-Output "Create Manifest for VLC"
New-GamutManifest -Category entertainment `
    -Publisher 'VideoLAN' `
    -Name 'VLC' `
    -Version '3.0.11' `
    -CopyrightNotice "Copyright (c) 2001-2020 VideoLAN" `
    -License 'GPL-2.0' `
    -LicenseURI 'http://www.videolan.org/legal.html' `
    -Tags @('vlc','multimedia','audio','video','mp3','dvd','avi','media player') `
    -Description 'VLC is a free and open source cross-platform multimedia player and framework that plays most multimedia files as well as DVD, Audio CD, VCD, and various streaming protocols.' `
    -Homepage 'https://www.videolan.org/' `
    -Arch @('x64','x86') `
    -Languages @('en-US') `
    -HasNuspec $true `
    -NuspecFile 'https://raw.githubusercontent.com/chocolatey-community/chocolatey-coreteampackages/master/automatic/vlc/vlc.nuspec' `
    -Depends @() `
    -InstallURI_x64 @('https://download.videolan.org/pub/videolan/vlc/last/win64/vlc-3.0.11-win64.msi') `
    -InstallURI_x86 @('https://download.videolan.org/pub/videolan/vlc/last/win32/vlc-3.0.11-win32.msi') `
    -MsiExe_x64 @('msi') `
    -MsiExe_x86 @('msi') `
    -InstallExe_x64 @('vlc-3.0.11-win64.msi') `
    -InstallExe_x86 @('vlc-3.0.11-win32.msi') `
    -InstallArgs_x64 @('/qn','/qn','/qn') `
    -InstallArgs_x86 @('/qn','/qn','/qn') `
    -UninstallExe_x64 @('C:\Windows\System32\msiexec.exe') `
    -UninstallExe_x86 @('C:\Windows\System32\msiexec.exe') `
    -UninstallArgs_x64 @('/x {0A1870BC-51B4-459D-B681-3B2033298122} /qn') `
    -UninstallArgs_x86 @('/x {162A5CE4-04E4-4879-9CFB-4C7A2171D85A} /qn') `
    -UpdateURI_x64 @('https://www.videolan.org/') `
    -UpdateURI_x86 @('https://www.videolan.org/') `
    -UpdateRegex_x64 @('') `
    -UpdateRegex_x86 @('') `
    -OutPath $Env:APPVEYOR_BUILD_FOLDER

Write-Output 'Test Manifest for VLC'
Get-ChildItem -Path 'C:\Projects\GamutManifestTool' -Filter 'latest.json' | ForEach-Object {
  Test-GamutManifest -FilePath $_.FullName
}
