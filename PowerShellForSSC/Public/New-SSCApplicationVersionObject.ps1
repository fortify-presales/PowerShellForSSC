function New-SSCApplicationVersionObject
{
    <#
    .SYNOPSIS
        Construct a new SSC Application Version Object.
    .DESCRIPTION
        Construct a new SSC Application Version Object.
        Note that this does not physically add the application version in SSC.
        It constructs an object to add with the Add-SSCApplicationVersion function.
    .PARAMETER ApplicationName
        The Name of the application to create.
    .PARAMETER ApplicationDescription
        The Description of the application.
        Optional.
    .PARAMETER ApplicationId
        The Id of an existing application.
        Note: Supply an 'ApplicationName' to create a new Application and Application Version
        or 'ApplicationId' to create Application Version in an existing Application. You can
        retrieve an Application id using Get-SSCApplicationId
    .PARAMETER VersionName
        The Name of the application version.
    .PARAMETER Description
        The Description of the application version.
        Optional.
    .PARAMETER IssueTemplateId
        The Id of the IssueTemplate to use for the application version
    .PARAMETER Active
        Activate the Application Version (visible in the UI).
        Default is $True.
    .PARAMETER CopyData
        Copy meta-data from an existing application version.
        Requires CopyVersionId to be specified.
    .PARAMETER CopyState
        Copy the current state of an existing application version.
    .PARAMETER CopyVersionId
        The Id of the application version to copy.
        Optional.
    .PARAMETER Attributes
        Collection of PS4SSC.AttributeObject's containing key/value pairs.
        Optional but some attributes may have been made mandatory for your application versions.
    .EXAMPLE
        # Create any AttributeObjects first - some might be mandatory
        $attributes = @(
            New-SSCAttributeObject -AttributeDefinitionId 5 -Value "New"
            New-SSCAttributeObject -AttributeDefinitionId 6 -Value "Internal"
            New-SSCAttributeObject -AttributeDefinitionId 7 -Value "internalnetwork"
            New-SSCAttributeObject -AttributeDefinitionId 1 -Value "High"
        )
        # Create the ApplicationVersionObject - creates a new application AND version
        $appVerObject = New-SSCApplicationVersionObject -ApplicationName "Test" -Name "1.0" -Description "its description" `
            -IssueTemplateId "Prioritized-HighRisk-Project-Template" -Attributes $attributes
        # Copy an existing application version
        $AppId = Get-SSCApplicationId -ApplicationName "Test"
        $VerId = Get-SSCApplicationVersionId -ApplicationName "Test" -VersionName "1.0"
        $appVerObject = New-SSCApplicationVersionObject -ApplicationId $AppId -Name "2.0" -Description "its description" `
            -IssueTemplateId "Prioritized-HighRisk-Project-Template" -Attributes $attributes -CopyData -CopyState -CopyVersionId $VerId
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable],[String])]
    param
    (
        [string]$ApplicationName,
        [string]$ApplicationDescription,
        [int]$ApplicationId,

        [int]$Id,
        [string]$Name,
        [string]$Description,

        [string]$IssueTemplateId,

        [bool]$Active = $True,
        [switch]$CopyData,
        [switch]$CopyState,

        [int]$CopyVersionId,

        [Parameter(Mandatory = $false,
                ValueFromPipeline = $true)]
        [PSTypeName('PS4SSC.AttributeObject')]
        [System.Collections.Hashtable[]]
        $Attributes
    )
    begin
    {
        $AllAttributes = @()
        if (-not $ApplicationId -and -not $ApplicationName) {
            throw "Please supply either an ApplicationName or ApplicationId"
        }
        if ($CopyData -and -not $CopyVersionId) {
            throw "A value for CopyVersionId is required if CopyData is selected"
        }
        if ($CopyState -and -not $CopyVersionId) {
            throw "A value for CopyVersionId is required if CopyState is selected"
        }
        Write-Verbose "New-SSCApplicationVersionObject Bound Parameters:  $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
    }
    process
    {
        foreach ($Attribute in $Attributes) {
            $AllAttributes += $Attribute
        }
    }
    end
    {
        $project = @{ }
        if ($ApplicationId -gt 0) {
            $project.Add("id", $ApplicationId)
        } else {
            $project.add("name", $ApplicationName)
            $project.add("description", $ApplicationDescription)
            $project.add("issueTemplateId", $IssueTemplateId)
        }
        $body = @{ }
        switch ($psboundparameters.keys)
        {
            'id'                        { $body.id = $Id }
            'active'                    {
                if ($Active) { $body.active = $true }
                else { $body.active = $false }
            }
            'name'                      { $body.name = $Name }
            'description'               { $body.description = $Description }
            'issueTemplateId'           { $body.issueTemplateId = $IssueTemplateId }
            'copyData'                 {
                if ($CopyData) { $body.copyData = $true }
                else { $body.copyData = $false }
            }
            'copyState'                 {
                if ($CopyState) { $body.copyState = $true }
                else { $body.copyState = $false }
            }
            'copyVersionId'             { $body.copyVersionId = $CopyVersionId }
            'attributes'                { $body.attributes = @($AllAttributes) }
        }
        $body.Add("project", $project)

        Add-ObjectDetail -InputObject $body -TypeName PS4SSC.ApplicationVersionObject
    }
}
