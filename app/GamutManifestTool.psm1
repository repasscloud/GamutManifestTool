#handle PS2
if (-not $PSScriptRoot) { 
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

#Pick and import assemblies:
if ($PSEdition -eq 'core') {
    if ($isLinux) {
        Write-Verbose "loading linux-x64 core"
        #$SQLiteAssembly = Join-path $PSScriptRoot "core\linux-x64\System.Data.SQLite.dll"
    }

    if ($isMacOS) {
        Write-Verbose "loading mac-x64 core"
        #$SQLiteAssembly = Join-path $PSScriptRoot "core\osx-x64\System.Data.SQLite.dll"
    }

    if ($isWindows) {
        if ([IntPtr]::size -eq 8) { #64
            Write-Verbose "loading win-x64 core"
            #$SQLiteAssembly = Join-path $PSScriptRoot "core\win-x64\System.Data.SQLite.dll"
        }
        elseif ([IntPtr]::size -eq 4) { #32
            Write-Verbose "loading win-x32 core"
            #$SQLiteAssembly = Join-path $PSScriptRoot "core\win-x86\System.Data.SQLite.dll"
        }
    }
    Write-Verbose -message "is PS Core, loading dotnet core dll"
}
elseif ([IntPtr]::size -eq 8) {  #64
    Write-Verbose -message "is x64, loading..."
    #$SQLiteAssembly = Join-path $PSScriptRoot "x64\System.Data.SQLite.dll"
}
elseif ([IntPtr]::size -eq 4) { #32
    #$SQLiteAssembly = Join-path $PSScriptRoot "x86\System.Data.SQLite.dll"
}
else {
    Throw "Something is odd with bitness..."
}

#Get public and private function definition files.
$Public=Get-ChildItem $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue
#$Private = Get-ChildItem $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue 

#Dot source the files
foreach ( $import in @($Public) ) {
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