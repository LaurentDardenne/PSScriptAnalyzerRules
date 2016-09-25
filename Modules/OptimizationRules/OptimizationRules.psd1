﻿#
# Module manifest for module 'ParameterSetRules'
#
# Generated by: Laurent Dardenne
#
# Generated on: 09/01/2016
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'OptimizationRules.psm1'

# Version number of this module.
ModuleVersion = '0.2.0'

# ID used to uniquely identify this module
GUID = '607465cd-bec6-46e4-81e5-768701bf35a0'

# Author of this module
Author = 'Laurent Dardenne'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = 'CopyLeft'

# Description of the functionality provided by this module
Description = 'This module contains script analyzer rules to search statements can be improved.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules=@(
#<DEFINE %DEBUG%>
 @{ModuleName="Log4Posh"; GUID="f796dd07-541c-4ad8-bfac-a6f15c4b06a0"; ModuleVersion="2.0.0"}
#<UNDEF %DEBUG%> 
 @{ModuleName="PSScriptAnalyzer"; GUID='d6245802-193d-4068-a631-8863a4342a18'; ModuleVersion="1.5.0"}
)

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

# Functions to export from this module
FunctionsToExport = @('Measure*')

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

