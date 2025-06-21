# Scripts Directory

This directory contains utility scripts for managing the JDKManager module.

## Available Scripts

### bump-version.ps1
Automatically bumps the module version in the manifest file.

**Usage:**
```powershell
# Bump patch version (1.0.0 -> 1.0.1)
.\scripts\bump-version.ps1 -BumpType patch

# Bump minor version (1.0.0 -> 1.1.0)
.\scripts\bump-version.ps1 -BumpType minor

# Bump major version (1.0.0 -> 2.0.0)
.\scripts\bump-version.ps1 -BumpType major
```

**What it does:**
- Reads current version from `JDKManager.psd1`
- Bumps the appropriate version component
- Updates the manifest file
- Validates the changes
- Provides next steps for publishing

## Version Bumping Guidelines

- **Patch** (1.0.0 → 1.0.1): Bug fixes, minor improvements
- **Minor** (1.0.0 → 1.1.0): New features, backward compatible
- **Major** (1.0.0 → 2.0.0): Breaking changes, major features

## Automated Publishing

When you push to the `master` branch, GitHub Actions will:
1. Validate the module
2. Extract the version from the manifest
3. Publish to PowerShell Gallery
4. Create a GitHub release with the new version 