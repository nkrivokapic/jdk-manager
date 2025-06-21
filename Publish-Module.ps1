# Publish JDKManager Module to PowerShell Gallery
# Run this script to publish your module

param(
    [string]$ApiKey,
    [string]$Repository = "PSGallery"
)

Write-Host "JDK Manager Module Publisher" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "JDKManager\JDKManager.psd1")) {
    Write-Error "JDKManager\JDKManager.psd1 not found. Please run this script from the module directory."
    exit 1
}

# Check if required files exist
$requiredFiles = @("JDKManager\JDKManager.psd1", "JDKManager\JDKManager.psm1", "JDKManager\README.md", "JDKManager\LICENSE")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Error "Required file not found: $file"
        exit 1
    }
}

Write-Host "Required files found." -ForegroundColor Green

# Test the module
Write-Host "`nTesting module..." -ForegroundColor Yellow
try {
    Import-Module .\JDKManager\JDKManager.psd1 -Force
    $functions = Get-Command -Module JDKManager
    Write-Host "Module loaded successfully. Found $($functions.Count) functions:" -ForegroundColor Green
    $functions | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
    Remove-Module JDKManager -Force
} catch {
    Write-Error "Module test failed: $_"
    exit 1
}

# Validate manifest
Write-Host "`nValidating module manifest..." -ForegroundColor Yellow
try {
    Test-ModuleManifest .\JDKManager\JDKManager.psd1
    Write-Host "Manifest validation passed." -ForegroundColor Green
} catch {
    Write-Error "Manifest validation failed: $_"
    exit 1
}

# Check if API key is provided
if (-not $ApiKey) {
    Write-Host "`nNo API key provided. You can:" -ForegroundColor Yellow
    Write-Host "1. Run: .\Publish-Module.ps1 -ApiKey 'your-api-key'" -ForegroundColor White
    Write-Host "2. Or set it interactively below" -ForegroundColor White
    $ApiKey = Read-Host "Enter your PowerShell Gallery API key"
}

if (-not $ApiKey) {
    Write-Error "API key is required to publish to PowerShell Gallery."
    exit 1
}

# Confirm before publishing
Write-Host "`nReady to publish to $Repository" -ForegroundColor Cyan
Write-Host "Module: JDKManager" -ForegroundColor White
Write-Host "Version: 1.0.0" -ForegroundColor White
Write-Host "Files to include:" -ForegroundColor White
Get-ChildItem -Name | Where-Object { $_ -in @("JDKManager.psd1", "JDKManager.psm1", "README.md", "LICENSE") } | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }

$confirm = Read-Host "`nDo you want to proceed with publishing? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Publishing cancelled." -ForegroundColor Yellow
    exit 0
}

# Publish the module
Write-Host "`nPublishing module to $Repository..." -ForegroundColor Yellow
try {
    Publish-Module -Path .\JDKManager -NuGetApiKey $ApiKey -Repository $Repository -Force
    Write-Host "`nModule published successfully!" -ForegroundColor Green
    Write-Host "You can now install it with: Install-Module -Name JDKManager" -ForegroundColor Cyan
} catch {
    Write-Error "Failed to publish module: $_"
    exit 1
} 