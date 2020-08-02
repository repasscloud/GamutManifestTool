<#
RePass Cloud isURIWeb.ps1
Copyright 2020 RePass Cloud Pty Ltd
This product includes software developed at
RePass Cloud (https://repasscloud.com/).
Version:
Last Updated:
#>

function isURIWeb ($address) {
    $uri = $address -as [System.Uri]
    $null -ne $uri.AbsoluteUri -and $uri.Scheme -match [regex]::new('(^http$)|(^https$)')
}
