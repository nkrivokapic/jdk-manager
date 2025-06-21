# JDK Manager PowerShell Module

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/JDKManager.svg?style=flat-square&label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/JDKManager)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/JDKManager.svg?style=flat-square)](https://www.powershellgallery.com/packages/JDKManager)
[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/nkrivokapic/jdk-manager/publish.yml?branch=master&style=flat-square&label=Build)](https://github.com/nkrivokapic/jdk-manager/actions)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg?style=flat-square&logo=powershell)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-10%2B-blue.svg?style=flat-square&logo=windows)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)

A PowerShell module for managing and switching between multiple JDK installations on Windows.

## License

MIT License

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