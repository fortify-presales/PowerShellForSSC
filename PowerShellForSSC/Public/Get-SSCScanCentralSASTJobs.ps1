function Get-SSCScanCentralSASTJobs {
    <#
    .SYNOPSIS
        Get SSC ScanCentral SAST Jobs.
    .DESCRIPTION
        Get information about SSC ScanCentral SAST Jobs.
    .PARAMETER Fields
        A comma separated list of fields to return.
    .PARAMETER Query
        A search-spec of full text search query.
    .PARAMETER OrderBy
        A comma separated list of fields to order by.
    .PARAMETER Start
        Starting offset for applications returned.
        Default is 0.
    .PARAMETER Limit
        Limit the number of applications returned to this number.
        If '-1' or '0' no limit is applied .
        Default is 200.
    .PARAMETER Raw
        If specified, provide raw output and do not parse any responses.
    .PARAMETER Token
        SSC token to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETER Proxy
        Proxy server to use.
        Default value is the value set by Set-SSCConfig
    .EXAMPLE
        # Get the first 50 jobs in the system
        Get-SSCScanCentralSASTJobs -Limit 50
     .EXAMPLE
        # Get any jobs where their jobState is "UPLOAD_COMPLETED"
        Get-SSCScanCentralSASTJobs -Query "jobState:UPLOAD_COMPLETED"
    .LINK
        http://localhost:8080/ssc/html/docs/api-reference/index.jsp#/cloud-job-controller/listCloudJob
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param (
        [string]$Fields,
        [string]$Query,
        [string]$OrderBy,
        [switch]$Raw,
        [int]$Start = 0,
        [int]$Limit = 200,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Token = $Script:PS4SSC.Token,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$SscUri = $Script:PS4SSC.SscUri,

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
        $Body = @{
            start = $Start
            limit = $Limit
        }
        if ($Fields) {
            $Body.Add("fields", $Fields)
        }
        if ($OrderBy) {
            $Body.Add("orderby", $OrderBy)
        }
        if ($Query) {
            $Body.Add("q", $Query)
        }
        $RawJobs = @()
        $TotalCount = 0
    }
    process
    {
        Write-Verbose "Send-SSCApi -Method Get -Operation 'api/v1/cloudjobs'" #$Params
        $Response = Send-SSCApi -Method Get -Operation "/api/v1/cloudjobs" -Body $Body @Params
        $TotalCount = $Response.count
        $RawJobs = $Response.data
        Write-Verbose "Retrieved $TotalCount jobs"
    }
    end {
        if ($Raw) {
            $RawJobs
        } else {
            Parse-SSCScanCentralSASTJob -InputObject $RawJobs
        }
    }
}
