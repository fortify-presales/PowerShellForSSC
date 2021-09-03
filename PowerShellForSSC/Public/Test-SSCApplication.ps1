function Test-SSCApplication {
    <#
    .SYNOPSIS
        Checks if an SSC application exists.
    .DESCRIPTION
        Checks if the specified SSC Application already exists.
        Returns $True if the application exists else $False.
    .PARAMETER ApplicationName
        The name of the application.
    .PARAMETER Token
        SSC token to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETER Proxy
        Proxy server to use.
        Default value is the value set by Set-SSCConfig
    .EXAMPLE
        # Test if the Application "test" exists
        Test-SSCApplication -ApplicationName "test"
     .LINK
        http://localhost:8080/html/docs/api-reference/index.jsp#/project-controller/testProject
     .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ApplicationName,

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
        Write-Verbose "Test-SSCApplication Bound Parameters: $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
        $Exists = $False
    }
    process
    {
        $Body = @{
            applicationName = $ApplicationName
        }
        $Params.Body = $Body
        try {
            Write-Verbose "Send-SSCApi -Method Post -Operation '/api/v1/projects/action/test'" #$Params
            $Response = Send-SSCApi -Method Post -Operation "/api/v1/projects/action/test" @Params
            $Exists = $Response.data.found
        } catch {
            $Exists = $False
        }
    }
    end {
        return $Exists
    }
}
