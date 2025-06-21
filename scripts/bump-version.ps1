# Version Bump Script for JDKManager Module
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("patch", "minor", "major")]
    [string]$BumpType,
    
    [string]$ManifestPath = ".\JDKManager\JDKManager.psd1"
)

Write-Host "Bumping version for JDKManager module..." -ForegroundColor Cyan

# Read current version
$manifest = Test-ModuleManifest $ManifestPath
$currentVersion = $manifest.Version
Write-Host "Current version: $currentVersion" -ForegroundColor Yellow

# Parse version components
$versionParts = $currentVersion -split '\.'
$major = [int]$versionParts[0]
$minor = [int]$versionParts[1]
$patch = [int]$versionParts[2]

# Bump version based on type
switch ($BumpType) {
    "major" {
        $major++
        $minor = 0
        $patch = 0
    }
    "minor" {
        $minor++
        $patch = 0
    }
    "patch" {
        $patch++
    }
}

$newVersion = "$major.$minor.$patch"
Write-Host "New version: $newVersion" -ForegroundColor Green

# Update manifest file
$manifestContent = Get-Content $ManifestPath -Raw
$manifestContent = $manifestContent -replace "ModuleVersion = '[\d\.]+'", "ModuleVersion = '$newVersion'"
Set-Content -Path $ManifestPath -Value $manifestContent -NoNewline

Write-Host "Version updated in $ManifestPath" -ForegroundColor Green

# Validate the updated manifest
try {
    Test-ModuleManifest $ManifestPath | Out-Null
    Write-Host "Manifest validation passed!" -ForegroundColor Green
} catch {
    Write-Error "Manifest validation failed: $_"
    exit 1
}

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Commit the version change: git add $ManifestPath" -ForegroundColor White
Write-Host "2. Commit: git commit -m 'Bump version to $newVersion'" -ForegroundColor White
Write-Host "3. Push to master: git push origin master" -ForegroundColor White
Write-Host "4. GitHub Actions will automatically publish v$newVersion to PowerShell Gallery" -ForegroundColor White 