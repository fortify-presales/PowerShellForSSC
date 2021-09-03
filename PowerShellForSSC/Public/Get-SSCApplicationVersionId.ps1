function Get-SSCApplicationVersionId {
    <#
    .SYNOPSIS
        Gets the id for an SSC application version.
    .DESCRIPTION
        Get the internal id for a specific SSC application version.
    .PARAMETER ApplicationName
        The application version name.
    .PARAMETER VersionName
        The application version name.
    .PARAMETER Raw
        If specified, provide raw output and do not parse any responses.
    .PARAMETER Token
        SSC token to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETER Proxy
        Proxy server to use.
        Default value is the value set by Set-SSCConfig
    .EXAMPLE
        # Get the id for the Application Version called "1.0" in Application "SSC-Test"
        Get-SSCApplicationVersionId -ApplicationName "SSC-Test" -VersionName "1.0"
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    param (
        [Parameter(Mandatory=$True)]
        [string]$ApplicationName,

        [Parameter(Mandatory=$True)]
        [string]$VersionName,

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
        $ApplicationVersions = @()
    }
    process
    {
        try {
            $ApplicationVersions = Get-SSCApplicationVersions -Query "project.name:$ApplicationName" | Where-Object { $_.name -eq $VersionName }
        } catch {
            Write-Error $_
            Break
        }
    }
    end {
        if ($Raw) {
            $ApplicationVersions
        } else {
            $ApplicationVersions | Select-Object -ExpandProperty id
        }
    }
}
