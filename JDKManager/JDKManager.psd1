@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'JDKManager.psm1'
    
    # Version number of this module.
    ModuleVersion = '1.0.3'
    
    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')
    
    # ID used to uniquely identify this module
    GUID = 'f8e9d7c6-b5a4-4321-8765-0987654321ab'
    
    # Author of this module
    Author = 'Nemanja Krivokapic'
    
    # Company or vendor of this module
    CompanyName = 'KNetwork Solutions'
    
    # Copyright statement for this module
    Copyright = '(c) 2025. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description = 'A PowerShell module for managing and switching between multiple JDK installations on Windows. Supports automatic JDK detection, custom paths, and environment management.'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'
    
    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''
    
    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''
    
    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''
    
    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''
    
    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''
    
    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()
    
    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-JDKInstallations',
        'Set-JDKVersion', 
        'Set-DefaultJDK',
        'Get-CurrentJDK',
        'Add-JDKPath',
        'Remove-JDKPath',
        'Get-CustomJDKPaths'
    )
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = '*'
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()
    
    # DSC resources to export from this module
    # DscResourcesToExport = @()
    
    # List of all modules packaged with this module
    # ModuleList = @()
    
    # List of all files packaged with this module
    FileList = @(
        'JDKManager.psm1',
        'README.md',
        'LICENSE'
    )
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also be a PSObject that contains additional module configuration used by the module.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Java', 'JDK', 'Development', 'Environment', 'Management', 'Windows')
            
            # A URL to the license for this module.
            LicenseUri = 'https://github.com/nkrivokapic/jdk-manager/blob/master/LICENSE'
            
            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/nkrivokapic/jdk-manager'
            
            # A URL to an icon representing this module.
            # IconUri = ''
            
            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release of JDK Manager PowerShell module. Features include automatic JDK detection, custom path management, and environment switching.'
            
            # Prerelease string of this module
            # Prerelease = ''
            
            # Flag to indicate whether the module requires explicit user acceptance for install, update, or save.
            RequireLicenseAcceptance = $false
            
            # External dependent modules of this module
            # ExternalModuleDependencies = @()
        } # End of PSData hashtable
    } # End of PrivateData hashtable
    
    # HelpInfo URI of this module
    # HelpInfoURI = ''
    
    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
} 