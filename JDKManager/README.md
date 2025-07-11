# JDK Manager PowerShell Module

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/JDKManager.svg?style=flat-square&label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/JDKManager)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/JDKManager.svg?style=flat-square)](https://www.powershellgallery.com/packages/JDKManager)
[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/nkrivokapic/jdk-manager/publish.yml?branch=master&style=flat-square&label=Build)](https://github.com/nkrivokapic/jdk-manager/actions)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg?style=flat-square&logo=powershell)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-10%2B-blue.svg?style=flat-square&logo=windows)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)

A PowerShell module for managing and switching between multiple JDK installations on Windows.

## Features

- **List JDK installations** - Discover all JDK versions installed on your system
- **Switch JDK versions** - Easily switch between different JDK installations
- **Set default JDK** - Configure a default JDK for your system (with automatic elevation)
- **Custom JDK paths** - Add and manage custom JDK installation paths
- **Environment management** - Automatically manage JAVA_HOME and PATH variables
- **Multi-source detection** - Scans registry, file system, and custom paths

## Installation

### From PowerShell Gallery (Recommended)
```powershell
Install-Module -Name JDKManager -Repository PSGallery
```

**Note**: If you encounter execution policy errors, you may need to adjust your PowerShell execution policy:
```powershell
# Check current execution policy
Get-ExecutionPolicy

# Set execution policy to allow signed scripts (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or set to allow all scripts (less secure, use with caution)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

### Manual Installation
1. Clone this repository
2. Copy the `JDKManager` folder to one of your PowerShell module paths:
   ```powershell
   # Check your module paths
   $env:PSModulePath -split ';'
   
   # Copy to user module path (recommended)
   Copy-Item -Path ".\JDKManager" -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\" -Recurse
   ```
3. Import the module:
   ```powershell
   Import-Module JDKManager
   ```

## Usage

### List all JDK installations
```powershell
Get-JDKInstallations
```

### Switch to a specific JDK version (current session only)
```powershell
Set-JDKVersion -Version "17.0.2"
```

### Switch to JDK by path (current session only)
```powershell
Set-JDKVersion -InstallPath "C:\Program Files\Java\jdk-17.0.2"
```

### Set default JDK (system-wide, requires elevation)
```powershell
Set-DefaultJDK -Version "17.0.2"
```
*Note: This will automatically elevate privileges if needed*

### Get current JDK information
```powershell
Get-CurrentJDK
```

### Add custom JDK path
```powershell
Add-JDKPath -Path "C:\MyJDKs\jdk-21"
```

### Remove custom JDK path
```powershell
# Remove by path
Remove-JDKPath -Path "C:\MyJDKs\jdk-21"

# Or remove interactively (shows numbered list)
Remove-JDKPath
```

### Get custom JDK paths
```powershell
Get-CustomJDKPaths
```

## Commands

| Command | Description |
|---------|-------------|
| `Get-JDKInstallations` | List all discovered JDK installations |
| `Set-JDKVersion` | Switch to a specific JDK version for current session |
| `Set-DefaultJDK` | Set the default JDK for the system (auto-elevates) |
| `Get-CurrentJDK` | Show currently active JDK |
| `Add-JDKPath` | Add a custom JDK installation path |
| `Remove-JDKPath` | Remove a custom JDK installation path |
| `Get-CustomJDKPaths` | Get list of custom JDK paths |

## JDK Detection Sources

The module automatically scans for JDK installations from multiple sources:

### Registry Locations
- Oracle JDK registry entries
- Eclipse Adoptium/Temurin registry entries
- Microsoft JDK registry entries
- Windows Uninstall registry

### File System Locations
- `C:\Program Files\Java`
- `C:\Program Files (x86)\Java`
- `C:\Program Files\Eclipse Adoptium`
- `C:\Program Files\Eclipse Foundation`
- `C:\Program Files\Amazon Corretto`
- `C:\Program Files\Microsoft\jdk`
- `C:\Program Files\Zulu\zulu-*`
- `C:\Program Files\BellSoft\LibericaJDK`
- `C:\Program Files\SAP\SapMachine`

### Custom Paths
- User-defined paths stored in `HKCU:\Software\JDKManager\CustomJDKs`

## Examples

### Basic Usage
```powershell
# Install from PowerShell Gallery
Install-Module -Name JDKManager

# See what JDKs are available
Get-JDKInstallations

# Switch to JDK 17 for this session
Set-JDKVersion -Version "17"

# Set JDK 17 as system default
Set-DefaultJDK -Version "17"

# Check current JDK
Get-CurrentJDK
```

### Custom JDK Management
```powershell
# Add a custom JDK path
Add-JDKPath -Path "D:\Development\jdk-21.0.1"

# List all JDKs (including custom ones)
Get-JDKInstallations

# Remove a custom path interactively
Remove-JDKPath
```

### Session vs System Changes
```powershell
# This only affects the current PowerShell session
Set-JDKVersion -Version "11"

# This affects the entire system (requires elevation)
Set-DefaultJDK -Version "17"
```

## Troubleshooting

### Execution Policy Issues
If you see an error about execution policies when importing the module:

```powershell
# Check your current execution policy
Get-ExecutionPolicy

# Set to allow signed scripts (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify the change
Get-ExecutionPolicy
```

### Module Not Found
If the module isn't found after installation:

```powershell
# Check if module is installed
Get-Module -ListAvailable -Name JDKManager

# Check module paths
$env:PSModulePath -split ';'

# Force reinstall
Uninstall-Module -Name JDKManager -AllVersions
Install-Module -Name JDKManager -Force
```

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges (for system-wide changes, auto-elevated)

## Notes

- **Session changes** (`Set-JDKVersion`) only affect the current PowerShell session
- **System changes** (`Set-DefaultJDK`) affect all users and persist across reboots
- Custom JDK paths are stored per-user in the Windows Registry
- The module automatically handles privilege elevation when needed
- Duplicate JDK installations are automatically filtered out

## Development

### Automated Publishing

This module uses GitHub Actions for automated publishing to PowerShell Gallery. When you push to the `master` branch:

1. **Automatic Validation**: The module is tested and validated
2. **Version Extraction**: Version is read from the manifest
3. **PowerShell Gallery Publishing**: Module is published to PSGallery
4. **GitHub Release**: A new release is created with the version

### Version Management

To bump the version before publishing:

```powershell
# Bump patch version (1.0.0 -> 1.0.1)
.\scripts\bump-version.ps1 -BumpType patch

# Bump minor version (1.0.0 -> 1.1.0)  
.\scripts\bump-version.ps1 -BumpType minor

# Bump major version (1.0.0 -> 2.0.0)
.\scripts\bump-version.ps1 -BumpType major
```

### Setup Required

To enable automated publishing, you need to add a GitHub secret:

1. Go to your GitHub repository → Settings → Secrets and variables → Actions
2. Add a new repository secret named `PSGALLERY_API_KEY`
3. Set the value to your PowerShell Gallery API key

The workflow will automatically use this secret to publish to PowerShell Gallery.

## License

MIT License 