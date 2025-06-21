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