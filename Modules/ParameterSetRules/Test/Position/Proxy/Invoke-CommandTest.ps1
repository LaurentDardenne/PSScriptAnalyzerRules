Function Invoke-CommandTest {
[CmdletBinding(DefaultParameterSetName='InProcess', HelpUri='http://go.microsoft.com/fwlink/?LinkID=135225', RemotingCapability='OwnedByCommand')]
param(
    [Parameter(ParameterSetName='Session', Position=0)]
    [Parameter(ParameterSetName='FilePathRunspace', Position=0)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.Runspaces.PSSession[]]
    ${Session},

    [Parameter(ParameterSetName='ComputerName', Position=0)]
    [Parameter(ParameterSetName='FilePathComputerName', Position=0)]
    [Alias('Cn')]
    [ValidateNotNullOrEmpty()]
    [string[]]
    ${ComputerName},

    [Parameter(ParameterSetName='ComputerName', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FilePathVMName', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FilePathVMId', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='Uri', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FilePathComputerName', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FilePathUri', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='VMId', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='VMName', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [pscredential]
    [System.Management.Automation.CredentialAttribute()]
    ${Credential},

    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='FilePathComputerName')]
    [ValidateRange(1, 65535)]
    [int]
    ${Port},

    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='FilePathComputerName')]
    [switch]
    ${UseSSL},

    [Parameter(ParameterSetName='ComputerName', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FilePathUri', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FilePathComputerName', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='Uri', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${ConfigurationName},

    [Parameter(ParameterSetName='FilePathComputerName', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ComputerName', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${ApplicationName},

    [Parameter(ParameterSetName='FilePathUri')]
    [Parameter(ParameterSetName='ContainerId')]
    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='Uri')]
    [Parameter(ParameterSetName='FilePathComputerName')]
    [Parameter(ParameterSetName='FilePathRunspace')]
    [Parameter(ParameterSetName='Session')]
    [Parameter(ParameterSetName='VMId')]
    [Parameter(ParameterSetName='VMName')]
    [Parameter(ParameterSetName='FilePathContainerId')]
    [Parameter(ParameterSetName='ContainerName')]
    [Parameter(ParameterSetName='FilePathVMId')]
    [Parameter(ParameterSetName='FilePathVMName')]
    [Parameter(ParameterSetName='FilePathContainerName')]
    [int]
    ${ThrottleLimit},

    [Parameter(ParameterSetName='Uri', Position=0)]
    [Parameter(ParameterSetName='FilePathUri', Position=0)]
    [Alias('URI','CU')]
    [ValidateNotNullOrEmpty()]
    [uri[]]
    ${ConnectionUri},

    [Parameter(ParameterSetName='FilePathRunspace')]
    [Parameter(ParameterSetName='FilePathContainerName')]
    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='Session')]
    [Parameter(ParameterSetName='Uri')]
    [Parameter(ParameterSetName='FilePathComputerName')]
    [Parameter(ParameterSetName='ContainerId')]
    [Parameter(ParameterSetName='FilePathUri')]
    [Parameter(ParameterSetName='VMId')]
    [Parameter(ParameterSetName='VMName')]
    [Parameter(ParameterSetName='ContainerName')]
    [Parameter(ParameterSetName='FilePathVMId')]
    [Parameter(ParameterSetName='FilePathVMName')]
    [Parameter(ParameterSetName='FilePathContainerId')]
    [switch]
    ${AsJob},

    [Parameter(ParameterSetName='Uri')]
    [Parameter(ParameterSetName='FilePathUri')]
    [Parameter(ParameterSetName='FilePathComputerName')]
    [Parameter(ParameterSetName='ComputerName')]
    [Alias('Disconnected')]
    [switch]
    ${InDisconnectedSession},

    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='FilePathComputerName')]
    [ValidateNotNullOrEmpty()]
    [string[]]
    ${SessionName},

    [Parameter(ParameterSetName='FilePathUri')]
    [Parameter(ParameterSetName='VMName')]
    [Parameter(ParameterSetName='FilePathContainerId')]
    [Parameter(ParameterSetName='Session')]
    [Parameter(ParameterSetName='Uri')]
    [Parameter(ParameterSetName='FilePathRunspace')]
    [Parameter(ParameterSetName='FilePathComputerName')]
    [Parameter(ParameterSetName='VMId')]
    [Parameter(ParameterSetName='ContainerId')]
    [Parameter(ParameterSetName='ContainerName')]
    [Parameter(ParameterSetName='FilePathVMId')]
    [Parameter(ParameterSetName='FilePathVMName')]
    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='FilePathContainerName')]
    [Alias('HCN')]
    [switch]
    ${HideComputerName},

    [Parameter(ParameterSetName='Uri')]
    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='Session')]
    [Parameter(ParameterSetName='FilePathContainerName')]
    [Parameter(ParameterSetName='FilePathComputerName')]
    [Parameter(ParameterSetName='FilePathRunspace')]
    [Parameter(ParameterSetName='FilePathUri')]
    [Parameter(ParameterSetName='ContainerId')]
    [Parameter(ParameterSetName='ContainerName')]
    [Parameter(ParameterSetName='FilePathContainerId')]
    [string]
    ${JobName},

    [Parameter(ParameterSetName='VMName', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='Session', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='Uri', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='InProcess', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='VMId', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='ComputerName', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='ContainerId', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='ContainerName', Mandatory=$true, Position=1)]
    [Alias('Command')]
    [ValidateNotNull()]
    [scriptblock]
    ${ScriptBlock},

    [Parameter(ParameterSetName='InProcess')]
    [switch]
    ${NoNewScope},

    [Parameter(ParameterSetName='FilePathUri', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='FilePathComputerName', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='FilePathRunspace', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='FilePathVMId', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='FilePathVMName', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='FilePathContainerId', Mandatory=$true, Position=1)]
    [Parameter(ParameterSetName='FilePathContainerName', Mandatory=$true, Position=1)]
    [Alias('PSPath')]
    [ValidateNotNull()]
    [string]
    ${FilePath},

    [Parameter(ParameterSetName='Uri')]
    [Parameter(ParameterSetName='FilePathUri')]
    [switch]
    ${AllowRedirection},

    [Parameter(ParameterSetName='FilePathComputerName')]
    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='Uri')]
    [Parameter(ParameterSetName='FilePathUri')]
    [System.Management.Automation.Remoting.PSSessionOption]
    ${SessionOption},

    [Parameter(ParameterSetName='FilePathComputerName')]
    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='FilePathUri')]
    [Parameter(ParameterSetName='Uri')]
    [System.Management.Automation.Runspaces.AuthenticationMechanism]
    ${Authentication},

    [Parameter(ParameterSetName='FilePathComputerName')]
    [Parameter(ParameterSetName='FilePathUri')]
    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='Uri')]
    [switch]
    ${EnableNetworkAccess},

    [Parameter(ParameterSetName='ContainerName')]
    [Parameter(ParameterSetName='ContainerId')]
    [Parameter(ParameterSetName='FilePathContainerId')]
    [Parameter(ParameterSetName='FilePathContainerName')]
    [switch]
    ${RunAsAdministrator},

    [Parameter(ValueFromPipeline=$true)]
    [psobject]
    ${InputObject},

    [Alias('Args')]
    [System.Object[]]
    ${ArgumentList},

    [Parameter(ParameterSetName='VMId', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FilePathVMId', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [Alias('VMGuid')]
    [ValidateNotNullOrEmpty()]
    [guid[]]
    ${VMId},

    [Parameter(ParameterSetName='FilePathVMName', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='VMName', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    ${VMName},

    [Parameter(ParameterSetName='FilePathContainerId', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ContainerId', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    ${ContainerId},

    [Parameter(ParameterSetName='ContainerName', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='FilePathContainerName', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    ${ContainerName},

    [Parameter(ParameterSetName='Uri')]
    [Parameter(ParameterSetName='ComputerName')]
    [string]
    ${CertificateThumbprint})

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Core\Invoke-Command', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
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

.ForwardHelpTargetName Microsoft.PowerShell.Core\Invoke-Command
.ForwardHelpCategory Cmdlet

#>

}
