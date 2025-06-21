# JDK Manager PowerShell Module
# Version: 1.0.0

# Module manifest
$PSDefaultParameterValues['*:Verbose'] = $true

# Module variables
$script:JDKRegistryPaths = @(
    "HKLM:\SOFTWARE\JavaSoft\JDK",
    "HKLM:\SOFTWARE\JavaSoft\Java Development Kit",
    "HKLM:\SOFTWARE\Eclipse Adoptium\JDK",
    "HKLM:\SOFTWARE\Eclipse Foundation\JDK",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

$script:CommonJDKPaths = @(
    "C:\Program Files\Java",
    "C:\Program Files (x86)\Java",
    "C:\Program Files\Eclipse Adoptium",
    "C:\Program Files\Eclipse Foundation",
    "C:\Program Files\Amazon Corretto",
    "C:\Program Files\Microsoft\jdk",
    "C:\Program Files\Zulu\zulu-*",
    "C:\Program Files\BellSoft\LibericaJDK",
    "C:\Program Files\SAP\SapMachine"
)

$script:CustomJDKRegistryKey = "HKCU:\Software\JDKManager\CustomJDKs"

function Get-JDKInstallations {
    <#
    .SYNOPSIS
        Discover and list all JDK installations on the system.
    
    .DESCRIPTION
        Scans the system for JDK installations by checking registry entries and common installation paths.
        Returns detailed information about each JDK installation found.
    
    .EXAMPLE
        Get-JDKInstallations
        Lists all discovered JDK installations with their details.
    
    .OUTPUTS
        PSCustomObject[] - Array of JDK installation objects
    #>
    [CmdletBinding()]
    param()
    
    Write-Verbose "Scanning for JDK installations..."
    
    $installations = @()
    
    # Scan registry for JDK installations
    foreach ($registryPath in $script:JDKRegistryPaths) {
        if (Test-Path $registryPath) {
            Write-Verbose "Scanning registry path: $registryPath"
            
            try {
                $subKeys = Get-ChildItem -Path $registryPath -ErrorAction SilentlyContinue
                foreach ($subKey in $subKeys) {
                    $installLocation = $null
                    $displayName = $null
                    $version = $null
                    
                    # Try to get installation location
                    try {
                        $installLocation = (Get-ItemProperty -Path $subKey.PSPath -Name "InstallLocation" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty InstallLocation).TrimEnd('\')
                    } catch {}
                    
                    # Try to get display name
                    try {
                        $displayName = Get-ItemProperty -Path $subKey.PSPath -Name "DisplayName" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName
                    } catch {}
                    
                    # Try to get version
                    try {
                        $version = Get-ItemProperty -Path $subKey.PSPath -Name "Version" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version
                    } catch {}
                    
                    # If we found an installation location, validate it
                    if ($installLocation -and (Test-Path $installLocation)) {
                        $javaExe = Join-Path $installLocation "bin\java.exe"
                        if (Test-Path $javaExe) {
                            $javaVersion = & $javaExe -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString().Split('"')[1] }
                            
                            $installations += [PSCustomObject]@{
                                Version = $javaVersion
                                DisplayName = $displayName
                                InstallPath = $installLocation
                                JavaExe = $javaExe
                                Source = "Registry"
                                RegistryKey = $subKey.PSPath
                            }
                        }
                    }
                }
            } catch {
                Write-Warning "Error scanning registry path $registryPath : $_"
            }
        }
    }
    
    # Scan common installation paths
    foreach ($basePath in $script:CommonJDKPaths) {
        if (Test-Path $basePath) {
            Write-Verbose "Scanning directory: $basePath"
            
            try {
                $jdkDirs = Get-ChildItem -Path $basePath -Directory -ErrorAction SilentlyContinue
                foreach ($jdkDir in $jdkDirs) {
                    $javaExe = Join-Path $jdkDir.FullName "bin\java.exe"
                    if (Test-Path $javaExe) {
                        try {
                            $javaVersion = & $javaExe -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString().Split('"')[1] }
                            
                            $installations += [PSCustomObject]@{
                                Version = $javaVersion
                                DisplayName = $jdkDir.Name
                                InstallPath = $jdkDir.FullName
                                JavaExe = $javaExe
                                Source = "FileSystem"
                                RegistryKey = $null
                            }
                        } catch {
                            Write-Warning "Error getting version from $javaExe : $_"
                        }
                    }
                }
            } catch {
                Write-Warning "Error scanning directory $basePath : $_"
            }
        }
    }
    
    # Scan custom JDK paths from registry
    $customPaths = Get-CustomJDKPaths
    foreach ($customPath in $customPaths) {
        if ($customPath -and (Test-Path $customPath)) {
            $javaExe = Join-Path $customPath "bin\java.exe"
            if (Test-Path $javaExe) {
                try {
                    $javaVersion = & $javaExe -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString().Split('"')[1] }
                    $installations += [PSCustomObject]@{
                        Version = $javaVersion
                        DisplayName = Split-Path $customPath -Leaf
                        InstallPath = $customPath
                        JavaExe = $javaExe
                        Source = "Custom"
                        RegistryKey = $script:CustomJDKRegistryKey
                    }
                } catch {
                    Write-Warning "Error getting version from $javaExe : $_"
                }
            }
        }
    }
    
    # Remove duplicates based on InstallPath
    $uniqueInstallations = $installations | Sort-Object InstallPath -Unique
    
    Write-Verbose "Found $($uniqueInstallations.Count) JDK installations"
    return $uniqueInstallations
}

function Set-JDKVersion {
    <#
    .SYNOPSIS
        Switch to a specific JDK version for the current session.
    
    .DESCRIPTION
        Sets the JAVA_HOME environment variable and updates the PATH to use the specified JDK version.
        This change is only effective for the current PowerShell session.
    
    .PARAMETER Version
        The JDK version to switch to (e.g., "17.0.2", "11.0.12")
    
    .PARAMETER InstallPath
        Direct path to JDK installation directory
    
    .EXAMPLE
        Set-JDKVersion -Version "17.0.2"
        Switches to JDK version 17.0.2 if found.
    
    .EXAMPLE
        Set-JDKVersion -InstallPath "C:\Program Files\Java\jdk-17.0.2"
        Switches to the JDK at the specified path.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = "ByVersion")]
        [string]$Version,
        
        [Parameter(ParameterSetName = "ByPath")]
        [string]$InstallPath
    )
    
    $targetJDK = $null
    
    if ($InstallPath) {
        if (Test-Path $InstallPath) {
            $javaExe = Join-Path $InstallPath "bin\java.exe"
            if (Test-Path $javaExe) {
                $targetJDK = [PSCustomObject]@{
                    InstallPath = $InstallPath
                    JavaExe = $javaExe
                }
            } else {
                throw "Java executable not found at $javaExe"
            }
        } else {
            throw "JDK installation path not found: $InstallPath"
        }
    } else {
        $installations = Get-JDKInstallations
        $targetJDK = $installations | Where-Object { $_.Version -like "*$Version*" } | Select-Object -First 1
        
        if (-not $targetJDK) {
            throw "JDK version '$Version' not found. Available versions: $($installations.Version -join ', ')"
        }
    }
    
    # Set JAVA_HOME for current session
    $env:JAVA_HOME = $targetJDK.InstallPath
    
    # Update PATH to prioritize the selected JDK
    $javaBinPath = Join-Path $targetJDK.InstallPath "bin"
    $currentPath = $env:PATH -split ';'
    
    # Remove any existing Java paths from PATH
    $filteredPath = $currentPath | Where-Object { 
        $_ -notlike "*\Java\*" -and 
        $_ -notlike "*\jdk*\*" -and 
        $_ -notlike "*\Eclipse*\*" -and
        $_ -notlike "*\Amazon Corretto\*" -and
        $_ -notlike "*\Microsoft\jdk\*" -and
        $_ -notlike "*\Zulu\*" -and
        $_ -notlike "*\BellSoft\*" -and
        $_ -notlike "*\SAP\*"
    }
    
    # Add the selected JDK's bin directory to the beginning of PATH
    $env:PATH = ($javaBinPath + ';' + ($filteredPath -join ';'))
    
    Write-Host "Switched to JDK at: $($targetJDK.InstallPath)" -ForegroundColor Green
    Write-Host "JAVA_HOME set to: $env:JAVA_HOME" -ForegroundColor Green
    
    # Verify the switch
    try {
        $currentVersion = & java -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString().Split('"')[1] }
        Write-Host "Current Java version: $currentVersion" -ForegroundColor Cyan
    } catch {
        Write-Warning "Could not verify Java version: $_"
    }
}

function Set-DefaultJDK {
    <#
    .SYNOPSIS
        Set the default JDK for the system (requires administrator privileges).
    
    .DESCRIPTION
        Sets the JAVA_HOME environment variable system-wide and updates the PATH to prioritize the selected JDK.
        This change affects all users and persists across reboots.
    
    .PARAMETER Version
        The JDK version to set as default (e.g., "17.0.2", "11.0.12")
    
    .PARAMETER InstallPath
        Direct path to JDK installation directory
    
    .EXAMPLE
        Set-DefaultJDK -Version "17.0.2"
        Sets JDK version 17.0.2 as the system default.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = "ByVersion")]
        [string]$Version,
        
        [Parameter(ParameterSetName = "ByPath")]
        [string]$InstallPath
    )
    
    # Check if running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "This command requires administrator privileges." -ForegroundColor Yellow
        Write-Host "Attempting to elevate privileges..." -ForegroundColor Cyan
        
        try {
            # Get the module path more reliably
            $modulePath = $null
            if ($MyInvocation.MyCommand.Module.Path) {
                $modulePath = $MyInvocation.MyCommand.Module.Path
            } else {
                # Try to find the module in the current directory
                $currentDir = Get-Location
                $modulePath = Join-Path $currentDir "JDKManager.psm1"
                if (-not (Test-Path $modulePath)) {
                    throw "Could not locate JDKManager.psm1 module file"
                }
            }
            
            $arguments = @()
            
            if ($Version) {
                $arguments += "-Version"
                $arguments += "`"$Version`""
            }
            if ($InstallPath) {
                $arguments += "-InstallPath"
                $arguments += "`"$InstallPath`""
            }
            
            # Build the PowerShell command
            $psCommand = "Import-Module '$modulePath'; Set-DefaultJDK $($arguments -join ' ')"
            
            # Start a new elevated PowerShell process
            $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-Command", $psCommand -Verb RunAs -Wait -PassThru -WindowStyle Hidden
            
            if ($process.ExitCode -ne 0) {
                Write-Error "Failed to set default JDK. Exit code: $($process.ExitCode)"
                Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
                return
            }
            
            Write-Host "Default JDK set successfully." -ForegroundColor Green
            return
        } catch {
            Write-Error "Failed to elevate privileges: $_"
            Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
            return
        }
    }
    
    $targetJDK = $null
    
    if ($InstallPath) {
        if (Test-Path $InstallPath) {
            $javaExe = Join-Path $InstallPath "bin\java.exe"
            if (Test-Path $javaExe) {
                $targetJDK = [PSCustomObject]@{
                    InstallPath = $InstallPath
                    JavaExe = $javaExe
                }
            } else {
                throw "Java executable not found at $javaExe"
            }
        } else {
            throw "JDK installation path not found: $InstallPath"
        }
    } else {
        $installations = Get-JDKInstallations
        $targetJDK = $installations | Where-Object { $_.Version -like "*$Version*" } | Select-Object -First 1
        
        if (-not $targetJDK) {
            throw "JDK version '$Version' not found. Available versions: $($installations.Version -join ', ')"
        }
    }
    
    # Set JAVA_HOME system-wide
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $targetJDK.InstallPath, [EnvironmentVariableTarget]::Machine)
    
    # Update system PATH
    $javaBinPath = Join-Path $targetJDK.InstallPath "bin"
    $currentSystemPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
    $pathArray = $currentSystemPath -split ';'
    
    # Remove any existing Java paths from system PATH
    $filteredPath = $pathArray | Where-Object { 
        $_ -notlike "*\Java\*" -and 
        $_ -notlike "*\jdk*\*" -and 
        $_ -notlike "*\Eclipse*\*" -and
        $_ -notlike "*\Amazon Corretto\*" -and
        $_ -notlike "*\Microsoft\jdk\*" -and
        $_ -notlike "*\Zulu\*" -and
        $_ -notlike "*\BellSoft\*" -and
        $_ -notlike "*\SAP\*"
    }
    
    # Add the selected JDK's bin directory to the beginning of system PATH
    $newSystemPath = ($javaBinPath + ';' + ($filteredPath -join ';'))
    [Environment]::SetEnvironmentVariable("PATH", $newSystemPath, [EnvironmentVariableTarget]::Machine)
    
    # Update current session environment variables
    $env:JAVA_HOME = $targetJDK.InstallPath
    $env:PATH = $newSystemPath
    
    Write-Host "System default JDK set to: $($targetJDK.InstallPath)" -ForegroundColor Green
    Write-Host "JAVA_HOME set system-wide to: $env:JAVA_HOME" -ForegroundColor Green
    Write-Host "Note: You may need to restart applications or open new command prompts for changes to take effect." -ForegroundColor Yellow
}

function Get-CurrentJDK {
    <#
    .SYNOPSIS
        Get information about the currently active JDK.
    
    .DESCRIPTION
        Returns information about the JDK that is currently active in the PATH.
    
    .EXAMPLE
        Get-CurrentJDK
        Shows information about the currently active JDK.
    #>
    [CmdletBinding()]
    param()
    
    try {
        $javaExe = Get-Command java -ErrorAction Stop
        $javaPath = $javaExe.Source
        $javaDir = Split-Path $javaPath -Parent
        $jdkRoot = Split-Path $javaDir -Parent
        
        $javaVersion = & java -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString().Split('"')[1] }
        
        return [PSCustomObject]@{
            Version = $javaVersion
            JavaExe = $javaPath
            InstallPath = $jdkRoot
            JAVA_HOME = $env:JAVA_HOME
        }
    } catch {
        Write-Warning "No Java installation found in PATH"
        return $null
    }
}

function Add-JDKPath {
    <#
    .SYNOPSIS
        Add a custom JDK installation path to the registry.
    .PARAMETER Path
        The path to the JDK installation directory.
    .EXAMPLE
        Add-JDKPath -Path "C:\MyJDKs\jdk-21"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    $jdkPath = $Path.TrimEnd('\')
    $javaExe = Join-Path $jdkPath "bin\java.exe"
    if (-not (Test-Path $jdkPath)) {
        throw "JDK path does not exist: $jdkPath"
    }
    if (-not (Test-Path $javaExe)) {
        throw "No java.exe found in $jdkPath\bin"
    }
    if (-not (Test-Path $script:CustomJDKRegistryKey)) {
        New-Item -Path $script:CustomJDKRegistryKey -Force | Out-Null
    }
    $existing = Get-ItemProperty -Path $script:CustomJDKRegistryKey -Name Paths -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Paths -ErrorAction SilentlyContinue
    $paths = @()
    if ($existing) {
        $paths = $existing -split ';'
    }
    if ($paths -contains $jdkPath) {
        Write-Host "Path already exists in custom JDKs: $jdkPath" -ForegroundColor Yellow
        return
    }
    $paths += $jdkPath
    Set-ItemProperty -Path $script:CustomJDKRegistryKey -Name Paths -Value ($paths -join ';')
    Write-Host "Added custom JDK path: $jdkPath" -ForegroundColor Green
}

function Remove-JDKPath {
    <#
    .SYNOPSIS
        Remove a custom JDK installation path from the registry.
    .PARAMETER Path
        The path to remove.
    .EXAMPLE
        Remove-JDKPath -Path "C:\MyJDKs\jdk-21"
    .EXAMPLE
        Remove-JDKPath
        Shows a numbered list of custom JDK paths and prompts for selection.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Path
    )
    
    if (-not (Test-Path $script:CustomJDKRegistryKey)) {
        Write-Host "No custom JDK paths configured." -ForegroundColor Yellow
        return
    }
    
    $existing = Get-ItemProperty -Path $script:CustomJDKRegistryKey -Name Paths -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Paths -ErrorAction SilentlyContinue
    if (-not $existing) {
        Write-Host "No custom JDK paths configured." -ForegroundColor Yellow
        return
    }
    
    $paths = $existing -split ';'
    
    # If no path specified, show numbered list and prompt for selection
    if (-not $Path) {
        Write-Host "`nAvailable custom JDK paths:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $paths.Count; $i++) {
            Write-Host "$($i + 1). $($paths[$i])" -ForegroundColor White
        }
        
        do {
            $selection = Read-Host "`nEnter the number of the path to remove (1-$($paths.Count))"
            $index = [int]$selection - 1
        } while ($index -lt 0 -or $index -ge $paths.Count -or -not [int]::TryParse($selection, [ref]$null))
        
        $jdkPath = $paths[$index]
    } else {
        $jdkPath = $Path.TrimEnd('\')
    }
    
    if ($paths -notcontains $jdkPath) {
        Write-Host "Path not found in custom JDKs: $jdkPath" -ForegroundColor Yellow
        return
    }
    
    $paths = $paths | Where-Object { $_ -ne $jdkPath }
    Set-ItemProperty -Path $script:CustomJDKRegistryKey -Name Paths -Value ($paths -join ';')
    Write-Host "Removed custom JDK path: $jdkPath" -ForegroundColor Green
}

function Get-CustomJDKPaths {
    [CmdletBinding()]
    param()
    if (-not (Test-Path $script:CustomJDKRegistryKey)) {
        return @()
    }
    $existing = Get-ItemProperty -Path $script:CustomJDKRegistryKey -Name Paths -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Paths -ErrorAction SilentlyContinue
    if (-not $existing) {
        return @()
    }
    return $existing -split ';'
}

# Export functions
Export-ModuleMember -Function @(
    'Get-JDKInstallations',
    'Set-JDKVersion',
    'Set-DefaultJDK',
    'Get-CurrentJDK',
    'Add-JDKPath',
    'Remove-JDKPath',
    'Get-CustomJDKPaths'
)