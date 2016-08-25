Function Add-AccessControlEntryTest {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [Alias('Path')]
    [System.Object]
    ${SDObject},

    [Parameter(ParameterSetName='AceObject', Mandatory=$true, Position=0)]
    [System.Object[]]
    ${AceObject},

    [switch]
    ${AddEvenIfAclDoesntExist},

    [switch]
    ${Apply},

    [switch]
    ${Force},

    [switch]
    ${PassThru},

    [Parameter(ParameterSetName='ProcessAccessRights')]
    [Parameter(ParameterSetName='ServiceAccessRights')]
    [Parameter(ParameterSetName='WmiNameSpaceRights')]
    [Parameter(ParameterSetName='PrinterRights')]
    [Parameter(ParameterSetName='LogicalShareRights')]
    [Parameter(ParameterSetName='ActiveDirectoryRightsObjectAceType')]
    [Parameter(ParameterSetName='ActiveDirectoryRights')]
    [Parameter(ParameterSetName='RegistryRights')]
    [Parameter(ParameterSetName='FolderRights')]
    [Parameter(ParameterSetName='FileRights')]
    [Parameter(ParameterSetName='GenericAccessMask')]
    [Parameter(ParameterSetName='AceObject')]
    [Alias('Set')]
    [switch]
    ${Overwrite},

    [Parameter(ParameterSetName='ProcessAccessRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ServiceAccessRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='WmiNameSpaceRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='PrinterRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='LogicalShareRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRightsObjectAceType', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='RegistryRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FolderRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FileRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='GenericAccessMask', ValueFromPipelineByPropertyName=$true)]
    [ValidateSet('AccessAllowed','AccessDenied','SystemAudit')]
    [string]
    ${AceType},

    [Parameter(ParameterSetName='ProcessAccessRights', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ServiceAccessRights', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='WmiNameSpaceRights', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='PrinterRights', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='LogicalShareRights', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRightsObjectAceType', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRights', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='RegistryRights', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FolderRights', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FileRights', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='GenericAccessMask', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('IdentityReference','SecurityIdentifier')]
    [System.Object]
    ${Principal},

    [Parameter(ParameterSetName='FileRights', Mandatory=$true)]
    [Alias('FileSystemRights')]
    [System.Security.AccessControl.FileSystemRights]
    ${FileRights},

    [Parameter(ParameterSetName='FolderRights', Mandatory=$true)]
    [System.Security.AccessControl.FileSystemRights]
    ${FolderRights},

    [Parameter(ParameterSetName='RegistryRights', Mandatory=$true)]
    [System.Security.AccessControl.RegistryRights]
    ${RegistryRights},

    [Parameter(ParameterSetName='ActiveDirectoryRights', Mandatory=$true)]
    [PowerShellAccessControl.ActiveDirectoryRights]
    ${ActiveDirectoryRights},

    [Parameter(ParameterSetName='GenericAccessMask', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [int]
    ${AccessMask},

    [Parameter(ParameterSetName='ProcessAccessRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ServiceAccessRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='WmiNameSpaceRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='PrinterRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='LogicalShareRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRightsObjectAceType', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='RegistryRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FolderRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FileRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='GenericAccessMask', ValueFromPipelineByPropertyName=$true)]
    [PowerShellAccessControl.AppliesTo]
    ${AppliesTo},

    [Parameter(ParameterSetName='ProcessAccessRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ServiceAccessRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='WmiNameSpaceRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='PrinterRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='LogicalShareRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRightsObjectAceType', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='RegistryRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FolderRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FileRights', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='GenericAccessMask', ValueFromPipelineByPropertyName=$true)]
    [switch]
    ${OnlyApplyToThisContainer},

    [Parameter(ParameterSetName='GenericAccessMask', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRightsObjectAceType', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRights', ValueFromPipelineByPropertyName=$true)]
    [System.Object]
    ${ObjectAceType},

    [Parameter(ParameterSetName='GenericAccessMask', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRightsObjectAceType', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ActiveDirectoryRights', ValueFromPipelineByPropertyName=$true)]
    [System.Object]
    ${InheritedObjectAceType},

    [Parameter(ParameterSetName='LogicalShareRights', Mandatory=$true)]
    [PowerShellAccessControl.LogicalShareRights]
    ${LogicalShareRights},

    [Parameter(ParameterSetName='PrinterRights', Mandatory=$true)]
    [PowerShellAccessControl.PrinterRights]
    ${PrinterRights},

    [Parameter(ParameterSetName='WmiNameSpaceRights', Mandatory=$true)]
    [PowerShellAccessControl.WmiNamespaceRights]
    ${WmiNameSpaceRights},

    [Parameter(ParameterSetName='ServiceAccessRights', Mandatory=$true)]
    [PowerShellAccessControl.ServiceAccessRights]
    ${ServiceAccessRights},

    [Parameter(ParameterSetName='ProcessAccessRights', Mandatory=$true)]
    [PowerShellAccessControl.ProcessAccessRights]
    ${ProcessAccessRights})

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Add-AccessControlEntry', [System.Management.Automation.CommandTypes]::Function)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline()
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process
{
    try {
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
<#

.ForwardHelpTargetName Add-AccessControlEntry
.ForwardHelpCategory Function

#>

}
