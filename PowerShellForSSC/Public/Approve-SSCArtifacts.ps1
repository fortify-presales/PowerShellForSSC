function Approve-SSCArtifacts {
    <#
    .SYNOPSIS
        Approve an SSC Artifact.
    .DESCRIPTION
        Approve one or more SSC Application Version artifcats for processing in spite of failing
    .PARAMETER Ids
        Comma separated list of artifact Ids to approve
    .PARAMETER Comment
        A comment to apply to the approval
    .EXAMPLE
        # Approve artifacts Ids 123 and 456
        Approve-SSCArtifacts -Ids 123,456 -Comment "Automatically approved"
    .LINK
        http://localhost:8080/ssc/html/docs/api-reference/index.jsp#/artifact-controller/approveArtifact
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [int[]]$Ids,

        [string]$Comment,

        [switch]$Raw = $False,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Token = $Script:PS4SSC.Token,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Uri = $Script:PS4SSC.ApiUri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Proxy = $Script:PS4SSC.Proxy,

        [switch]$ForceVerbose = $Script:PS4SSC.ForceVerbose
    )
    begin
    {
        if ($Ids.Count -gt 1) {
            throw "Sorry, the SSC API currently only supports a single artifact id..."
        }
        $Params = @{}
        if ($Proxy) {
            $Params['Proxy'] = $Proxy
        }
        if ($ForceVerbose) {
            $Params.Add('ForceVerbose', $True)
            $VerbosePreference = "Continue"
        }
        Write-Verbose "Approve-SSCArtifacts Bound Parameters:  $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
    }
    process
    {
        $Body = @{
            artifactIds = $Ids
        }
        $Body.Add("comment", $Comment)
        $Params.Body = $Body
        Write-Verbose "Send-SSCApi -Method Post -Operation 'api/v1/artifacts/action/approve'" #$Params
        $Response = Send-SSCApi -Method Post -Operation "/api/v1/artifacts/action/approve" @Params
    }
    end
    {

    }
}
