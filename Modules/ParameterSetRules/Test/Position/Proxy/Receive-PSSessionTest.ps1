Function Receive-PSSessionTest {
[CmdletBinding(DefaultParameterSetName='Session', SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=217037', RemotingCapability='OwnedByCommand')]
param(
    [Parameter(ParameterSetName='Session', Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.Runspaces.PSSession]
    ${Session},

    [Parameter(ParameterSetName='Id', Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [int]
    ${Id},

    [Parameter(ParameterSetName='ComputerSessionName', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ComputerInstanceId', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [Alias('Cn')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${ComputerName},

    [Parameter(ParameterSetName='ComputerInstanceId', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ComputerSessionName', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${ApplicationName},

    [Parameter(ParameterSetName='ConnectionUriSessionName', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ComputerSessionName', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ComputerInstanceId', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ConnectionUriInstanceId', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${ConfigurationName},

    [Parameter(ParameterSetName='ConnectionUriInstanceId', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ConnectionUriSessionName', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [Alias('URI','CU')]
    [ValidateNotNullOrEmpty()]
    [uri]
    ${ConnectionUri},

    [Parameter(ParameterSetName='ConnectionUriInstanceId')]
    [Parameter(ParameterSetName='ConnectionUriSessionName')]
    [switch]
    ${AllowRedirection},

    [Parameter(ParameterSetName='InstanceId', Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ComputerInstanceId', Mandatory=$true)]
    [Parameter(ParameterSetName='ConnectionUriInstanceId', Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [guid]
    ${InstanceId},

    [Parameter(ParameterSetName='ConnectionUriSessionName', Mandatory=$true)]
    [Parameter(ParameterSetName='SessionName', Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ComputerSessionName', Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    ${Name},

    [Parameter(ParameterSetName='ComputerInstanceId')]
    [Parameter(ParameterSetName='Session')]
    [Parameter(ParameterSetName='Id')]
    [Parameter(ParameterSetName='ComputerSessionName')]
    [Parameter(ParameterSetName='InstanceId')]
    [Parameter(ParameterSetName='ConnectionUriSessionName')]
    [Parameter(ParameterSetName='SessionName')]
    [Parameter(ParameterSetName='ConnectionUriInstanceId')]
    [Microsoft.PowerShell.Commands.OutTarget]
    ${OutTarget},

    [Parameter(ParameterSetName='InstanceId')]
    [Parameter(ParameterSetName='ConnectionUriSessionName')]
    [Parameter(ParameterSetName='ConnectionUriInstanceId')]
    [Parameter(ParameterSetName='ComputerInstanceId')]
    [Parameter(ParameterSetName='SessionName')]
    [Parameter(ParameterSetName='ComputerSessionName')]
    [Parameter(ParameterSetName='Session')]
    [Parameter(ParameterSetName='Id')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${JobName},

    [Parameter(ParameterSetName='ComputerSessionName')]
    [Parameter(ParameterSetName='ConnectionUriSessionName')]
    [Parameter(ParameterSetName='ComputerInstanceId')]
    [Parameter(ParameterSetName='ConnectionUriInstanceId')]
    [pscredential]
    [System.Management.Automation.CredentialAttribute()]
    ${Credential},

    [Parameter(ParameterSetName='ConnectionUriInstanceId')]
    [Parameter(ParameterSetName='ComputerSessionName')]
    [Parameter(ParameterSetName='ConnectionUriSessionName')]
    [Parameter(ParameterSetName='ComputerInstanceId')]
    [System.Management.Automation.Runspaces.AuthenticationMechanism]
    ${Authentication},

    [Parameter(ParameterSetName='ComputerSessionName')]
    [Parameter(ParameterSetName='ConnectionUriSessionName')]
    [Parameter(ParameterSetName='ConnectionUriInstanceId')]
    [Parameter(ParameterSetName='ComputerInstanceId')]
    [string]
    ${CertificateThumbprint},

    [Parameter(ParameterSetName='ComputerInstanceId')]
    [Parameter(ParameterSetName='ComputerSessionName')]
    [ValidateRange(1, 65535)]
    [int]
    ${Port},

    [Parameter(ParameterSetName='ComputerSessionName')]
    [Parameter(ParameterSetName='ComputerInstanceId')]
    [switch]
    ${UseSSL},

    [Parameter(ParameterSetName='ComputerInstanceId')]
    [Parameter(ParameterSetName='ComputerSessionName')]
    [Parameter(ParameterSetName='ConnectionUriInstanceId')]
    [Parameter(ParameterSetName='ConnectionUriSessionName')]
    [System.Management.Automation.Remoting.PSSessionOption]
    ${SessionOption})

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Core\Receive-PSSession', [System.Management.Automation.CommandTypes]::Cmdlet)
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

.ForwardHelpTargetName Microsoft.PowerShell.Core\Receive-PSSession
.ForwardHelpCategory Cmdlet

#>

}
