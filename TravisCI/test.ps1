if ($TRAVIS_CI_BUILD) {
    Write-Host "This is a TRAVIS-CI build"
}

if ($CAT_IN_THE_HAT) {
    Write-Output $CAT_IN_THE_HAT
}
