function Test-SSCApplicationVersion {
    <#
    .SYNOPSIS
        Checks if an SSC application version exists.
    .DESCRIPTION
        Checks if the specified SSC Application Version already exists in an SSC Application.
        Returns $True if the application version exists else $False.
    .PARAMETER ApplicationName
        The name of the application.
    .PARAMETER VersionName
        The name of the application version.
    .PARAMETER Token
        SSC token to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETER Proxy
        Proxy server to use.
        Default value is the value set by Set-SSCConfig
    .EXAMPLE
        # Test if the Application name "test" has an Application Version named "1.0"
        Test-SSCApplicationVersion -ApplicationName "test" -ApplicationVersionName "1.0"
    .LINK
        http://localhost:8080/html/docs/api-reference/index.jsp#/project-version-controller/testProjectVersion
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ApplicationName,

        [Parameter(Mandatory)]
        [string]$VersionName,

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
        Write-Verbose "Test-SSCApplicationVersion Bound Parameters: $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
        $Exists = $False
    }
    process
    {
        $Body = @{
            projectName = $ApplicationName
            projectVersionName = $VersionName
        }
        $Params.Body = $Body
        try {
            Write-Verbose "Send-SSCApi -Method Post -Operation '/api/v1/projectVersions/action/test'" #$Params
            $Response = Send-SSCApi -Method Post -Operation "/api/v1/projectVersions/action/test" @Params
            $Exists = $Response.data.found
        } catch {
            $Exists = $False
        }
    }
    end {
        return $Exists
    }
}
