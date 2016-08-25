Function Where-ObjectTest {
[CmdletBinding(DefaultParameterSetName='EqualSet', HelpUri='http://go.microsoft.com/fwlink/?LinkID=113423', RemotingCapability='None')]
param(
    [Parameter(ValueFromPipeline=$true)]
    [psobject]
    ${InputObject},

    [Parameter(ParameterSetName='ScriptBlockSet', Mandatory=$true, Position=0)]
    [scriptblock]
    ${FilterScript},

    [Parameter(ParameterSetName='NotEqualSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveNotInSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='NotInSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='LessOrEqualSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveInSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='IsSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='EqualSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveEqualSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='IsNotSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveNotEqualSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='GreaterThanSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveGreaterThanSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='LessThanSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveLessThanSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='GreaterOrEqualSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveGreaterOrEqualSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveMatchSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='InSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='LikeSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveLikeSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='NotLikeSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveNotLikeSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='MatchSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveLessOrEqualSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='NotMatchSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveNotMatchSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='ContainsSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveContainsSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='NotContainsSet', Mandatory=$true, Position=0)]
    [Parameter(ParameterSetName='CaseSensitiveNotContainsSet', Mandatory=$true, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]
    ${Property},

    [Parameter(ParameterSetName='InSet', Position=1)]
    [Parameter(ParameterSetName='LessThanSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveLessThanSet', Position=1)]
    [Parameter(ParameterSetName='EqualSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveNotEqualSet', Position=1)]
    [Parameter(ParameterSetName='GreaterOrEqualSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveGreaterOrEqualSet', Position=1)]
    [Parameter(ParameterSetName='LessOrEqualSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveLessOrEqualSet', Position=1)]
    [Parameter(ParameterSetName='LikeSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveLikeSet', Position=1)]
    [Parameter(ParameterSetName='NotLikeSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveNotMatchSet', Position=1)]
    [Parameter(ParameterSetName='ContainsSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveContainsSet', Position=1)]
    [Parameter(ParameterSetName='NotContainsSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveNotLikeSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveNotContainsSet', Position=1)]
    [Parameter(ParameterSetName='IsNotSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveInSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveEqualSet', Position=1)]
    [Parameter(ParameterSetName='NotInSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveNotInSet', Position=1)]
    [Parameter(ParameterSetName='IsSet', Position=1)]
    [Parameter(ParameterSetName='MatchSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveMatchSet', Position=1)]
    [Parameter(ParameterSetName='NotMatchSet', Position=1)]
    [Parameter(ParameterSetName='NotEqualSet', Position=1)]
    [Parameter(ParameterSetName='GreaterThanSet', Position=1)]
    [Parameter(ParameterSetName='CaseSensitiveGreaterThanSet', Position=1)]
    [System.Object]
    ${Value},

    [Parameter(ParameterSetName='EqualSet')]
    [Alias('IEQ')]
    [switch]
    ${EQ},

    [Parameter(ParameterSetName='CaseSensitiveEqualSet', Mandatory=$true)]
    [switch]
    ${CEQ},

    [Parameter(ParameterSetName='NotEqualSet', Mandatory=$true)]
    [Alias('INE')]
    [switch]
    ${NE},

    [Parameter(ParameterSetName='CaseSensitiveNotEqualSet', Mandatory=$true)]
    [switch]
    ${CNE},

    [Parameter(ParameterSetName='GreaterThanSet', Mandatory=$true)]
    [Alias('IGT')]
    [switch]
    ${GT},

    [Parameter(ParameterSetName='CaseSensitiveGreaterThanSet', Mandatory=$true)]
    [switch]
    ${CGT},

    [Parameter(ParameterSetName='LessThanSet', Mandatory=$true)]
    [Alias('ILT')]
    [switch]
    ${LT},

    [Parameter(ParameterSetName='CaseSensitiveLessThanSet', Mandatory=$true)]
    [switch]
    ${CLT},

    [Parameter(ParameterSetName='GreaterOrEqualSet', Mandatory=$true)]
    [Alias('IGE')]
    [switch]
    ${GE},

    [Parameter(ParameterSetName='CaseSensitiveGreaterOrEqualSet', Mandatory=$true)]
    [switch]
    ${CGE},

    [Parameter(ParameterSetName='LessOrEqualSet', Mandatory=$true)]
    [Alias('ILE')]
    [switch]
    ${LE},

    [Parameter(ParameterSetName='CaseSensitiveLessOrEqualSet', Mandatory=$true)]
    [switch]
    ${CLE},

    [Parameter(ParameterSetName='LikeSet', Mandatory=$true)]
    [Alias('ILike')]
    [switch]
    ${Like},

    [Parameter(ParameterSetName='CaseSensitiveLikeSet', Mandatory=$true)]
    [switch]
    ${CLike},

    [Parameter(ParameterSetName='NotLikeSet', Mandatory=$true)]
    [Alias('INotLike')]
    [switch]
    ${NotLike},

    [Parameter(ParameterSetName='CaseSensitiveNotLikeSet', Mandatory=$true)]
    [switch]
    ${CNotLike},

    [Parameter(ParameterSetName='MatchSet', Mandatory=$true)]
    [Alias('IMatch')]
    [switch]
    ${Match},

    [Parameter(ParameterSetName='CaseSensitiveMatchSet', Mandatory=$true)]
    [switch]
    ${CMatch},

    [Parameter(ParameterSetName='NotMatchSet', Mandatory=$true)]
    [Alias('INotMatch')]
    [switch]
    ${NotMatch},

    [Parameter(ParameterSetName='CaseSensitiveNotMatchSet', Mandatory=$true)]
    [switch]
    ${CNotMatch},

    [Parameter(ParameterSetName='ContainsSet', Mandatory=$true)]
    [Alias('IContains')]
    [switch]
    ${Contains},

    [Parameter(ParameterSetName='CaseSensitiveContainsSet', Mandatory=$true)]
    [switch]
    ${CContains},

    [Parameter(ParameterSetName='NotContainsSet', Mandatory=$true)]
    [Alias('INotContains')]
    [switch]
    ${NotContains},

    [Parameter(ParameterSetName='CaseSensitiveNotContainsSet', Mandatory=$true)]
    [switch]
    ${CNotContains},

    [Parameter(ParameterSetName='InSet', Mandatory=$true)]
    [Alias('IIn')]
    [switch]
    ${In},

    [Parameter(ParameterSetName='CaseSensitiveInSet', Mandatory=$true)]
    [switch]
    ${CIn},

    [Parameter(ParameterSetName='NotInSet', Mandatory=$true)]
    [Alias('INotIn')]
    [switch]
    ${NotIn},

    [Parameter(ParameterSetName='CaseSensitiveNotInSet', Mandatory=$true)]
    [switch]
    ${CNotIn},

    [Parameter(ParameterSetName='IsSet', Mandatory=$true)]
    [switch]
    ${Is},

    [Parameter(ParameterSetName='IsNotSet', Mandatory=$true)]
    [switch]
    ${IsNot})

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Core\Where-Object', [System.Management.Automation.CommandTypes]::Cmdlet)
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

.ForwardHelpTargetName Microsoft.PowerShell.Core\Where-Object
.ForwardHelpCategory Cmdlet

#>

}
