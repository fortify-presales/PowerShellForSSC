function Get-SSCScanCentralSASTJob {
    <#
    .SYNOPSIS
        Get an SSC ScanCentral SAST job.
    .DESCRIPTION
        Get information about a specific SSC ScanCentral SAST Job.
    .PARAMETER JobToken
        The token of the job.
    .PARAMETER Fields
        A comma separated list of fields to return.
    .PARAMETER Raw
        If specified, provide raw output and do not parse any responses.
    .PARAMETER Token
        SSC token to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETER Proxy
        Proxy server to use.
        Default value is the value set by Set-SSCConfig
    .EXAMPLE
        # Get the jobState and pvId fields of job with token 7be71c88-df2d-45fa-9b59-11cfe9d1404a
        Get-SSCScanCentralSASTJob -JobToken 7be71c88-df2d-45fa-9b59-11cfe9d1404a -Fields "jobState,pvId"
    .LINK
        http://localhost:8080/ssc/html/docs/api-reference/index.jsp#/cloud-job-controller/readCloudJob
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [string]$JobToken,

        [string]$Fields,

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
        Write-Verbose "Get-SSCScanCentralSASTJobs Bound Parameters: $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
        $RawJob = $null
    }
    process
    {
        $OpUri = "/api/v1/cloudjobs/$JobToken"
        if ($Fields) {
            $OpUri = $OpUri + "?fields=" + [System.Web.HTTPUtility]::UrlEncode($Fields)
        }
        Write-Verbose "Send-SSCApi -Method Get -Operation '$OpUri'" #$Params
            $Response = Send-SSCApi -Method Get -Operation "$OpUri" @Params
            $RawJob = $Response.data
    }
    end {
        if ($Raw) {
            $RawJob
        } else {
            Parse-SSCScanCentralSASTJob -InputObject $RawJob
        }
    }
}
