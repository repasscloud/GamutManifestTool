#Requires -Version 5.1
#Requires -Module Get.URLStatusCode
#Requires -Module GetRedirectedUrl
#Requires -Module PSWriteColor

function Test-GamutManifest {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false,
            HelpMessage='Path to Manifest JSON file.',
            Position=0)]
            [ValidateScript({
                if (-not ($_ | Test-Path) ) {
                    throw "'$_' is NOT a valid file path."
                }
                if (-not ($_ | Test-Path -PathTyp Leaf) ){
                    throw "The FilePath argument must be a file. Directories paths are not allowed."
                }
                if ($_ -notmatch "(\.json)") {
                    throw "The file specified in the FilePath argument must be of type 'json'."
                }
                return $true
            })]
        [Alias('path')]
        [System.IO.FileInfo]$FilePath
    )

    begin {
        # Set TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12

        # Encoding utf-8
        [Console]::OutputEncoding=[System.Text.Encoding]::UTF8

        # Set Temp directory variable to $dir_tmp by OS selection, with backwards compatibility for Windows PS5.1
        if ($IsWindows -or $ENV:OS) {
            [String]$dir_tmp=$Env:TEMP
        } else {
            if ($IsLinux) {
                Write-Output "Linux"  #~> This needs to be tested still
            }
            elseif ($IsMacOS) {
                [String]$dir_tmp=$Env:TMPDIR
            }
        }

        # Create temporary file
        [String]$file_tmp=[System.IO.Path]::Combine($dir_tmp,$([System.GUID]::NewGUID().Guid))

        # Set UserAgent for downloading data
        #$userAgent=[Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
    }
    process {
        # Load Manifest file
        $jsonData=Get-Content -Path $FilePath -Raw | ConvertFrom-Json

        # Valid Chocolatey Nuspec file
        if ($jsonData.Nuspec) {

            # Create temporary file
            [String]$file_tmp=[System.IO.Path]::Combine($dir_tmp,$([System.GUID]::NewGUID().Guid))
            
            # Manifest version used
            $jClient=[System.Net.WebClient]::new()
            $jString=$jClient.DownloadString('https://raw.githubusercontent.com/repasscloud/software-library/master/lib/public/manifest_version.json')
            $jClient.Dispose()
            $jString=$jString | ConvertFrom-Json
            if ([System.Version]$jsonData.Manifest -ge [System.Version]$jString.Manifest_Version) {
                Write-Color 'Using CMani:' -Color Gray
                Write-Color '  [',$([char]8730),'] ',$jsonData.Manifest -Color Cyan,Green,Cyan,Yellow
            }
            else {
                Write-Color 'Using Manifest:' -Color Gray
                Write-Color '  [',$([char]215),'] ','Not latest version!' -Color Cyan,Red,Cyan,Yellow
            }

            # Current version from Chocolatey
            if ($jsonData.Nuspec -eq $true) {
                $wClient=[System.Net.WebClient]::new()
                [xml]$wString=$wClient.DownloadString($jsonData.NuspecURI)
                $wClient.Dispose()
                Write-Color 'Nuspec File:' -Color Gray
                Write-Color '  [',$([char]8730),'] ','Provided' -Color Cyan,Green,Cyan,Yellow
            }
            else {
                Write-Color 'Nuspec File:' -Color Gray
                Write-Color '  [',$([char]215),'] ','Not Provided' -Color Cyan,Red,Cyan,Yellow
            }

            # Verify if version 
            [System.Version]$ChocoVersion=$wString.package.metadata.version
            if ($ChocoVersion -gt [System.Version]$jsonData.Id.Version) {
                Write-Color 'App Version:' -Color Gray
                Write-Color '  [',$([char]215),']  ','Not latest version! Rebuild using New-GamutManifest first.' -Color Cyan,Red,Cyan,Yellow
            }
            else {
                Write-Color 'App Version:' -Color Gray
                Write-Color '  [',$([char]8730),']' -Color Cyan,Green,Cyan
            }

            # Publisher
            Write-Color 'Publisher:' -Color Gray
            Write-Color "  $($jsonData.Id.Publisher)" -Color Yellow

            # Name
            Write-Color 'Name:' -Color Gray
            Write-Color "  $($jsonData.Id.Name)" -Color Yellow

            # Version
            Write-Color 'Version:' -Color Gray
            Write-Color "  $($jsonData.Id.Version)" -Color Yellow

            # License
            Write-Color 'License:' -Color Gray
            Write-Color "  $($jsonData.Id.License)" -Color Yellow

            # Depends
            Write-Color 'Depends:' -Color Gray
            if ($jsonData.Id.Depends) {
                Write-Color "  $($jsonData.Id.Depends)" -Color Yellow
            }
            else {
                Write-Color "  n/a" -Color Yellow
            }

            # Arch
            Write-Color 'Arch:' -Color Gray
            foreach ($i in $jsonData.Id.Arch) {
                Write-Color "  ~> $($i)" -Color Yellow
            }
            
            # Languages
            Write-Color 'Languages:' -Color Gray
            foreach ($i in $jsonData.Id.Languages) {
                Write-Color "  ~> $($i)" -Color Yellow
            }

            # Download tests
            $t=[System.GUID]::NewGUID().Guid
            foreach ($arch in $jsonData.Id.Arch) {
                foreach ($language in $jsonData.Id.Languages) {
                    Write-Color 'Downloading:' -Color Gray
                    Write-Color "  $($arch)",' in ',"$($language):" -Color Gray,Yellow,Gray
                    if ($IsWindows -or $Env:OS) {
                        [String]$dir_tmp=$Env:TEMP
                    } else {
                        if ($IsLinux) {
                            Write-Output "Linux"
                        }
                        elseif ($IsMacOS) {
                            [String]$dir_tmp=$Env:TMPDIR
                        }
                    }
                    [uri]$url=$jsonData.Id.Installers.$arch.$language.FollowURI
                    switch (isURIWeb -address $url) {
                        $true {
                            [String]$output=[System.IO.Path]::Combine($dir_tmp,$t,$jsonData.Id.Installers.$arch.$language.InstallExe)
                            New-Item -Path $(Split-Path -Path $output -Parent) -Force -Confirm:$false -ItemType Directory | Out-Null
                            $wc=New-Object System.Net.WebClient
                            $wc.DownloadFile($url.AbsoluteUri,$output)
                            $wc.Dispose()
                            switch ((Get-FileHash -Path $output -Algorithm SHA512).Hash -like $jsonData.Id.Installers.$arch.$language.Sha512) {
                                $true {
                                    Write-Color '    [',$([char]8730),'] ','SHA512 match!' -Color Cyan,Green,Cyan,Yellow
                                }
                                Default {
                                    Write-Color '    [',$([char]215),'] ','SHA512 mismatch! Rebuild using New-GamutManifest first.' -Color Cyan,Red,Cyan,Yellow
                                }
                            }
                        }
                        default {
                            Write-Color '    [',$([char]215),'] ','Invalid URL to download! Rebuild using New-GamutManifest first.' -Color Cyan,Red,Cyan,Yellow
                        }
                    }
                }
            }
        }
    }
    end {
        [System.GC]::Collect()
    }
}


Test-GamutManifest -FilePath .\app\Mozilla\Firefox\latest.json



<#
for($I = 1; $I -lt 101; $I++ )
{
    Write-Progress -Activity Updating -Status 'Progress->' -PercentComplete $I -CurrentOperation OuterLoop
    for($j = 1; $j -lt 101; $j++ )
    {
        Write-Progress -Id 1 -Activity Updating -Status 'Progress' -PercentComplete $j -CurrentOperation InnerLoop
        Start-Sleep -Milliseconds 50
    }
}
#>

#Write-Color '   [',$([char]215),']' -Color Cyan,Red,Cyan
#Write-Color '   [',$([char]8730),']' -Color Cyan,Green,Cyan