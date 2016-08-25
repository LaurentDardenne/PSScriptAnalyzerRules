# position $Name=1 (PSN default)
# position $ArgumentList=2 (PSN class)
# Invoke-WmiMethodTest -Name 'test' # -> $Class mandatory 
 
Function Invoke-WmiMethodTest {
[CmdletBinding(DefaultParameterSetName='class', SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=113346', RemotingCapability='OwnedByCommand')]
param(
    [Parameter(ParameterSetName='object', Mandatory=$true, ValueFromPipeline=$true)]
    [wmi]
    ${InputObject},

    [Parameter(ParameterSetName='path', Mandatory=$true)]
    [string]
    ${Path},

    [Parameter(ParameterSetName='class', Mandatory=$true, Position=0)]
    [string]
    ${Class},

    [Parameter(Mandatory=$true, Position=1)]
    [string]
    ${Name},

    [Parameter(ParameterSetName='object')]
    [Parameter(ParameterSetName='class', Position=2)]
    [Parameter(ParameterSetName='path')]
    [Alias('Args')]
    [System.Object[]]
    ${ArgumentList},

    [switch]
    ${AsJob},

    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='list')]
    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='query')]
    [System.Management.ImpersonationLevel]
    ${Impersonation},

    [Parameter(ParameterSetName='list')]
    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='query')]
    [System.Management.AuthenticationLevel]
    ${Authentication},

    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='list')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='query')]
    [string]
    ${Locale},

    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='list')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='query')]
    [switch]
    ${EnableAllPrivileges},

    [Parameter(ParameterSetName='list')]
    [Parameter(ParameterSetName='query')]
    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='WQLQuery')]
    [string]
    ${Authority},

    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='query')]
    [Parameter(ParameterSetName='list')]
    [pscredential]
    [System.Management.Automation.CredentialAttribute()]
    ${Credential},

    [int]
    ${ThrottleLimit},

    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='query')]
    [Parameter(ParameterSetName='list')]
    [Alias('Cn')]
    [ValidateNotNullOrEmpty()]
    [string[]]
    ${ComputerName},

    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='list')]
    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='query')]
    [Alias('NS')]
    [string]
    ${Namespace})

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Invoke-WmiMethod', [System.Management.Automation.CommandTypes]::Cmdlet)
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

.ForwardHelpTargetName Microsoft.PowerShell.Management\Invoke-WmiMethod
.ForwardHelpCategory Cmdlet

#>

}
