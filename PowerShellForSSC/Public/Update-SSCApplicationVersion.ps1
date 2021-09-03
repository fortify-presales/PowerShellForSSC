function Update-SSCApplicationVersion {
    <#
    .SYNOPSIS
        Updates an existing SSC application version.
    .DESCRIPTION
        Updates an existing SSC application version using the SSC REST API and a previously created
        PS4SSC.ApplicationVersionObject.
    .PARAMETER ApplicationVersion
        A PS4SSC.ApplicationVersion containing the application version's values.
    .PARAMETER Raw
        Print Raw output - do not convert into an ApplicationVersionObject.
        Default is false.
    .PARAMETER Token
        SSC authentication token to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETER Proxy
        Proxy server to use.
        Default value is the value set by Set-SSCConfig
    .PARAMETER ForceVerbose
        Force verbose output.
        Default value is the value set by Set-SSCConfig
    .EXAMPLE
        # Updates an existing application version
        $verResponse = Update-SSCApplicationVersion -Id 100 -ApplicationVersion $verObject
        if ($verResponse) {
            Write-Host "Updated application version with id:" $verResponse.id
        }
    .LINK
        http://localhost:8080/html/docs/api-reference/index.jsp#/project-version-controller/updateProjectVersion
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [int]$Id,

        [PSTypeName('PS4SSC.ApplicationVersionObject')]
        [parameter(ParameterSetName = 'SSCApplicationVersionObject',
                ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        $ApplicationVersion,

        [switch]$Raw = $False,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Token = $Script:PS4SSC.Token,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Uri = $Script:PS4SSC.ApiUri,

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
        Write-Verbose "Update-SSCApplicationVersion Bound Parameters:  $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
        $RawAppVer = @()
        if ($Id) {
            Write-Verbose "Checking if Application Version $Id exists"
            try {
                $Response = Get-SSCApplicationVersion -Id $Id
            } catch {
                throw "Cannot find Application Version with Id: $Id"
            }
            Write-Verbose "Application Version $Id exists"
        } else {
            throw "An Application Version Id is required"
        }
    }
    process
    {
        # Create temporary file to store JSON content for debugging.
        $TempFile = New-TemporaryFile
        $TempFileName = $TempFile.FullName
        Write-Verbose "Created temporary file: $TempFileName"

        # Update the Application Version (and Application if needed)
        $Attributes = $ApplicationVersion.attributes
        $ApplicationVersion.Remove("attributes")
        #$ApplicationVersion.Add("id", $Id)
        $ApplicationVersion.Add("committed", $True)
        $JsonOutput = $ApplicationVersion | ConvertTo-Json -Depth 10
        Set-Content -Path $TempFile.FullName -Value $JsonOutput
        $Params.Add('BodyFile', $TempFile.FullName)
        Write-Verbose "Send-SSCApi: -Method Put -Operation '/api/v1/projectVersions/$Id'"
        $Response = Send-SSCApi -Method Put -Operation "/api/v1/projectVersions/$Id" @Params
        $AppVerId = $Response.data.id
        if ($AppVerId -gt 0) {
            Write-Verbose "Updating application version with id: $AppVerId"
        } else {
            throw "Error updating version"
        }

        # Set the attributes of the Application version
        $JsonOutput = $Attributes | ConvertTo-Json -Depth 10
        Set-Content -Path $TempFile.FullName -Value $JsonOutput
        Write-Verbose "Send-SSCApi: -Method Put -Operation '/api/v1/projectVersions/$AppVerId/attributes'"
        Send-SSCApi -Method Put -Operation "/api/v1/projectVersions/$AppVerId/attributes" @Params | Out-Null
        Write-Verbose "Updated attributes on $AppVerId"

        # Retrieve the updated Application Version
        $Params.Remove('BodyFile')
        Write-Verbose "Send-SSCApi -Method Get -Operation '/api/v1/projectVersions/$AppVerId'" #$Params
        $Response = Send-SSCApi -Method Get -Operation "/api/v1/projectVersions/$AppVerId" @Params
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
