function Get-SSCApplication {
    <#
    .SYNOPSIS
        Get an SSC application.
    .DESCRIPTION
        Get information about a specific SSC application.
    .PARAMETER Id
        The id of the application.
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
        # Get the name and description fields of application with id 1
        Get-SSCApplication -Id 1 -Fields "name,description"
    .EXAMPLE
        # Get the application with name "SSC-TEST" using "Get-SSCApplicationId" in pipeline
        Get-SSCApplicationId -ApplicationName SSC-TEST | Get-SSCApplication
    .LINK
        http://localhost:8080/html/docs/api-reference/index.jsp#/project-controller/readProject
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
        Write-Verbose "Get-SSCApplication Bound Parameters: $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
        $RawApplication = $null
    }
    process
    {
        $OpUri = "/api/v1/projects/$Id"
        if ($Fields) {
            $OpUri = $OpUri + "?fields=" + [System.Web.HTTPUtility]::UrlEncode($Fields)
        }
        Write-Verbose "Send-SSCApi -Method Get -Operation '$OpUri'" #$Params
            $Response = Send-SSCApi -Method Get -Operation "$OpUri" @Params
            $RawApplication = $Response.data
    }
    end {
        if ($Raw) {
            $RawApplication
        } else {
            Parse-SSCApplication -InputObject $RawApplication
        }
    }
}
