function Get-SSCApplicationVersion {
    <#
    .SYNOPSIS
        Get an SSC application version.
    .DESCRIPTION
        Get information about a specific SSC application version.
    .PARAMETER Id
        The id of the application version.
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
        # Get the application version with id 1
        Get-SSCApplicationVersion -Id 1
    .EXAMPLE
        # Get the name and description fields of application version with id 1
        Get-SSCApplicationVersion -Id 1 -Fields "name,description"
    .EXAMPLE
        # Get the application version with name "SSC-TEST" using "Get-SSCApplicationVersionId" in pipeline
        Get-SSCApplicationVersionId -VersionName SSC-TEST | Get-SSCApplicationVersion
    .LINK
        http://localhost:8080/html/docs/api-reference/index.jsp#/project-controller/readProjectVersion
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [int]$Id,

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
        Write-Verbose "Get-SSCApplicationVersion Bound Parameters: $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
        $RawApplicationVersion = $null
    }
    process
    {
        $OpUri = "/api/v1/projectVersions/$Id"
        if ($Fields) {
            $OpUri = $OpUri + "?fields=" + [System.Web.HTTPUtility]::UrlEncode($Fields)
        }
        Write-Verbose "Send-SSCApi -Method Get -Operation '$OpUri'" #$Params
        $Response = Send-SSCApi -Method Get -Operation "$OpUri" @Params
        $RawApplicationVersion = $Response.data
    }
    end {
        if ($Raw) {
            $RawApplicationVersion
        } else {
            Parse-SSCApplicationVersion -InputObject $RawApplicationVersion
        }
    }
}
