function Get-SSCApplicationId {
    <#
    .SYNOPSIS
        Gets the id for an SSC application.
    .DESCRIPTION
        Get the internal id for a specific SSC application.
    .PARAMETER ApplicationName
        The application name.
    .PARAMETER Raw
        If specified, provide raw output and do not parse any responses.
    .PARAMETER Token
        SSC token to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETER Proxy
        Proxy server to use.
        Default value is the value set by Set-SSCConfig
    .EXAMPLE
        # Get the id for the Application called "SSC-Test"
        Get-SSCApplicationId -ApplicationName "SSC-Test"
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    param (
        [Parameter(Mandatory=$True)]
        [string]$ApplicationName,

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
        $Applications = @()
    }
    process
    {
        try {
            $Applications = Get-SSCApplications -Query "name:$ApplicationName"
        } catch {
            Write-Error $_
            Break
        }
    }
    end {
        if ($Raw) {
            $Applications
        } else {
            $Applications | Select-Object -ExpandProperty id
        }
    }
}
