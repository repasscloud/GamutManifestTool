#handle PS2
if (-not $PSScriptRoot) { 
    $dir_Root=Split-Path $MyInvocation.MyCommand.Path -Parent
}
else {
    $dir_Root=$PSScriptRoot
}

#Pick and import assemblies:
if ($PSEdition -eq 'core') {
    if ($isLinux) {
        Write-Verbose "loading linux-x64 core"
        #$SQLiteAssembly = Join-path $dir_Root "core\linux-x64\System.Data.SQLite.dll"
    }

    if ($isMacOS) {
        Write-Verbose "loading mac-x64 core"
        #$SQLiteAssembly = Join-path $dir_Root "core\osx-x64\System.Data.SQLite.dll"
    }

    if ($isWindows) {
        if ([IntPtr]::size -eq 8) { #64
            Write-Verbose "loading win-x64 core"
            #$SQLiteAssembly = Join-path $dir_Root "core\win-x64\System.Data.SQLite.dll"
        }
        elseif ([IntPtr]::size -eq 4) { #32
            Write-Verbose "loading win-x32 core"
            #$SQLiteAssembly = Join-path $dir_Root "core\win-x86\System.Data.SQLite.dll"
        }
    }
    Write-Verbose -message "is PS Core, loading dotnet core dll"
}
elseif ([IntPtr]::size -eq 8) {  #64
    Write-Verbose -message "is x64, loading..."
    #$SQLiteAssembly = Join-path $dir_Root "x64\System.Data.SQLite.dll"
}
elseif ([IntPtr]::size -eq 4) { #32
    #$SQLiteAssembly = Join-path $dir_Root "x86\System.Data.SQLite.dll"
}
else {
    Throw "Something is odd with bitness..."
}

#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $dir_Root\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $dir_Root\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
foreach ( $import in @($Public + $Private) ) {
    try {
        #PS2 compatibility
        if ($import.FullName) {
            . $import.FullName
        }
    }
    catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

#Create some aliases, export public functions
Export-ModuleMember -Function $($Public | Select-Object -ExpandProperty BaseName)