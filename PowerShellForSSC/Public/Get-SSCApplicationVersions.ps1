function Get-SSCApplicationVersions {
    <#
    .SYNOPSIS
        Get SSC application versions.
    .DESCRIPTION
        Get information about SSC application versions.
    .PARAMETER Fields
        A comma separated list of fields to return.
    .PARAMETER FullTextSearch
        If 'true', interpret 'Query' as full text search query, defaults to 'false'.
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
        # Get the first 50 applications in the system
        Get-SSCApplicationVersions -Limit 50
     .EXAMPLE
        # Get any application versionss with search string "bank" in their fields, e.g. name, description etc.
        Get-SSCApplicationVersions -FullTextSearch -Query "bank"
    .LINK
        http://localhost:8080/html/docs/api-reference/index.jsp#/project-version-controller/listProjectVersion
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param (
        [string]$Fields,
        [switch]$FullTextSearch,
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
        Write-Verbose "Get-SSCApplicationVersions Bound Parameters: $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
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
        if ($FullTextSearch) {
            $Body.Add("fulltextsearch", $true)
        } else {
            $Body.Add("fulltextsearch", $false)
        }
        if ($Query) {
            $Body.Add("q", $Query)
        }
        $RawApplicationVersions = @()
        $TotalCount = 0
    }
    process
    {
        Write-Verbose "Send-SSCApi -Method Get -Operation '/api/v1/projectVersions'" #$Params
        $Response = Send-SSCApi -Method Get -Operation "/api/v1/projectVersions" -Body $Body @Params
        $TotalCount = $Response.count
        $RawApplicationVersions = $Response.data
        Write-Verbose "Retrieved $TotalCount application versions"
    }
    end {
        if ($Raw) {
            $RawApplicationVersions
        } else {
            Parse-SSCApplicationVersion -InputObject $RawApplicationVersions
        }
    }
}
