function Remove-SSCApplicationVersion {
    <#
    .SYNOPSIS
        Deletes an SSC application version.
    .DESCRIPTION
        Deletes a specific SSC application version.
    .PARAMETER Id
        The id of the application version.
    .PARAMETER Raw
        If specified, provide raw output and do not parse any responses.
    .PARAMETER Token
        SSC token to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETER Proxy
        Proxy server to use.
        Default value is the value set by Set-SSCConfig
    .EXAMPLE
        # Remove the application version with id 100
        Remove-SSCApplicationVersion -Id 100
    .LINK
        http://localhost:8080/html/docs/api-reference/index.jsp#/project-version-controller/deleteProjectVersion
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [int]$Id,

        [switch]$Raw,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Token = $Script:PS4SSC.Token,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ApiUri = $Script:PS4SSC.ApiUri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Proxy = $Script:PS4SSC.Proxy,

        [switch]$ForceVerbose = $Script:PS4SSC.ForceVerbose
    )
    begin
    {
        $Params = @{}
        if ($Proxy) {
            $Params['Proxy'] = $Proxy
        }
        if ($ForceVerbose) {
            $Params.Add('ForceVerbose', $True)
            $VerbosePreference = "Continue"
        }
        Write-Verbose "Remove-SSCApplicationVersion Bound Parameters: $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
        $RawResponse = $null
    }
    process
    {
            Write-Verbose "Send-SSCApi -Method Delete -Operation '/api/v1/projectVersions/$Id'" #$Params
            $RawResponse = Send-SSCApi -Method Delete -Operation "/api/v1/projectVersions/$Id" @Params
    }
    end {
        if ($Raw) {
            $RawResponse
        } else {
            Parse-SSCResponse -InputObject $RawResponse
        }
    }
}
