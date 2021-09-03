function Add-SSCApplicationVersion {
    <#
    .SYNOPSIS
        Adds a new SSC application version.
    .DESCRIPTION
        Adds a new SSC application version using the SSC REST API and a previously created
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
        # Add a new application version
        $verResponse = Add-SSCApplicationVersion -ApplicationVersion $verObject
        if ($verResponse) {
            Write-Host "Created application version with id:" $verResponse.id
        }
    .LINK
        http://localhost:8080/html/docs/api-reference/index.jsp#/project-version-controller/createProjectVersion
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param (
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
        Write-Verbose "Add-SSCApplicationVersion Bound Parameters:  $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
        $AppId = $ApplicationVersion.project.id
        $AppName = $ApplicationVersion.project.name
        if ($AppId) {
            Write-Verbose "Checking if Application id $AppId exists"
            $AppResponse = Get-SSCApplication -Id $AppId
            if ($AppResponse.id -gt 0) {
                $AppName = $AppResponse.name
                Write-Verbose "Application exists with name: $AppName"
            }
        } elseif ($AppName) {
            Write-Verbose "Checking if Application $AppName exists"
            $AppId = Get-SSCApplicationId -ApplicationName $AppName
            if ($AppId -gt 0) {
                Write-Verbose "Application $AppName exists with id: $AppId"
                $Project = @{
                    id = $AppId
                }
                $ApplicationVersion.Remove("project")
                $ApplicationVersion.Add("project", $Project)
                $ApplicationVersion
            } else {
                Write-Verbose "Application $AppName does not exist and will be created"
            }
        } else {
            throw "Please supply and Application Id or Name"
        }
        $AppVerName = $ApplicationVersion.Name
        if ($AppVerName) {
            Write-Verbose "Checking if Application Version $AppVerName exists"
            if (Test-SSCApplicationVersion -ApplicationName $AppName -VersionName $AppVerName) {
                throw "Application version $AppVerName already exists in application $AppName"
            } else {
                Write-Verbose "Application version $AppVerName does not exist and will be created"
            }
        }
    }
    process
    {
        # Create temporary file to store JSON content for debugging.
        $TempFile = New-TemporaryFile
        $TempFileName = $TempFile.FullName
        Write-Verbose "Created temporary file: $TempFileName"

        # Create the Application version (and Application if needed)
        $ApplicationVersion.committed = $False
        $Attributes = $ApplicationVersion.attributes
        $ApplicationVersion.Remove("attributes")
        $JsonOutput = $ApplicationVersion | ConvertTo-Json -Depth 10
        Set-Content -Path $TempFile.FullName -Value $JsonOutput
        $Params.Add('BodyFile', $TempFile.FullName)
        Write-Verbose "Send-SSCApi: -Method Post -Operation '/api/v1/projectVersions'"
        $Response = Send-SSCApi -Method Post -Operation "/api/v1/projectVersions" @Params
        $AppVerId = $Response.data.id
        if ($AppVerId -gt 0) {
            Write-Verbose "Creating application version with id: $AppVerId"
        } else {
            throw "Error creating version"
        }

        # Set the attributes of the Application version
        $JsonOutput = $Attributes | ConvertTo-Json -Depth 10
        Set-Content -Path $TempFile.FullName -Value $JsonOutput
        Write-Verbose "Send-SSCApi: -Method Put -Operation '/api/v1/projectVersions/$AppVerId/attributes'"
        Send-SSCApi -Method Put -Operation "/api/v1/projectVersions/$AppVerId/attributes" @Params | Out-Null
        Write-Verbose "Created attributes on $AppVerId"

        # TODO: Set authenticated users

        #{
        #    "uri": "http://localhost:9090/api/v1/projectVersions/18/authEntities",
        #    "httpVerb": "PUT",
        #    "postData": [
        #    {
        #        "id": 2,
        #        "isLdap": false
        #    }
        #    ]
        #}

        # Copy meta-data from an existing application version
        if ($ApplicationVersion.CopyData) {
            $PrevAppVer = $ApplicationVersion.CopyVersionId
            Write-Verbose "Copying data from application version: $PrevAppVer"
            $CopyData = @{
                type = "COPY_FROM_PARTIAL"
                values = @{
                    copyAnalysisProcessingRules = $True
                    copyBugTrackerConfiguration = $True
                    copyCustomTags = $True
                    copyUserAccessSettings = $True
                    copyVersionAttributes = $True
                    previousProjectVersionId = $PrevAppVer
                    projectVersionId = $AppVerId
                }
            }
            $JsonOutput = $CopyData | ConvertTo-Json -Depth 10
            Set-Content -Path $TempFile.FullName -Value $JsonOutput
            Write-Verbose "Send-SSCApi: -Method Post -Operation '/api/v1/projectVersions/$AppVerId/action'"
            Send-SSCApi -Method Post -Operation "/api/v1/projectVersions/$AppVerId/action" @Params | Out-Null
        }

        # Commit the Application Version so its usable in UI
        $Committed = @{
            committed = $True
        }
        $JsonOutput = $Committed | ConvertTo-Json -Depth 10
        Set-Content -Path $TempFile.FullName -Value $JsonOutput
        Write-Verbose "Send-SSCApi: -Method Put -Operation '/api/v1/projectVersions/$AppVerId'"
        Send-SSCApi -Method Put -Operation "/api/v1/projectVersions/$AppVerId" @Params | Out-Null
        Write-Verbose "Committed application version $AppVerId"

        # If copying existing versions state, start the background copy
        if ($ApplicationVersion.CopyState) {
            $PrevAppVer = $ApplicationVersion.CopyVersionId
            Write-Verbose "Copying state from application version: $PrevAppVer"
            $CopyState = @{
                type = "COPY_CURRENT_STATE"
                values = @{
                    projectVersionId = $AppVerId
                    previousProjectVersionId = $PrevAppVer
                }
            }
            $JsonOutput = $CopyState | ConvertTo-Json -Depth 10
            Set-Content -Path $TempFile.FullName -Value $JsonOutput
            Write-Verbose "Send-SSCApi: -Method Post -Operation '/api/v1/projectVersions/$AppVerId/action'"
            Send-SSCApi -Method Post -Operation "/api/v1/projectVersions/$AppVerId/action" @Params | Out-Null
        }

        # Retrieve the new Application Version
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
