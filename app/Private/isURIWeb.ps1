function isURIWeb ($address) {
    $uri = $address -as [System.URI]
    $null -ne $uri.AbsoluteURI -and $uri.Scheme -match '[http|https]'
}