function isURIWeb ($address) {
    $uri = $address -as [System.Uri]
    $null -ne $uri.AbsoluteUri -and $uri.Scheme -match [regex]::new('(^http$)|(^https$)')
}
