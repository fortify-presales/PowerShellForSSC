function New-SSCAttributeObject
{
    <#
    .SYNOPSIS
        Construct a new SSC Attribute Object.
    .DESCRIPTION
        Construct a new SSC Attribute Object.
        Note that this does not physically add the attribute in SSC.
        It constructs an application object to add with the Add-SSCAttribute function or refers to
        an existing attribute object to passed into the Add-SSCApplication function.
    .PARAMETER Id
        The Id of the attribute.
        Note: you do not need to set this parameter to add a new attribute, it is used to store the id
        of a previously created attribute when this is object is used for Get-SSCAttribute(s) and New-SSCApplicationVersion.
    .PARAMETER AttributeDefinitionId
        The Attribute Definition Id of the attribute.
    .PARAMETER Name
        The Name of the attribute.
    .PARAMETER Value
        The value of the attribute.
    .EXAMPLE
        # This is a simple example illustrating how to create an attribute object.
        $myAttr1 = New-SSCAttributeObject -AttributeDefinitionId 5 -Value "New"  # DevPhase attribute id
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable],[String])]
    param
    (
        [int]$AttributeDefinitionId,
        [string]$Value
    )
    begin
    {
        Write-Verbose "New-SSCAttributeObject Bound Parameters:  $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
    }
    process
    {

    }
    end
    {
        $body = @{}
        $values = @(
            [PSCustomObject]@{
                PSTypeName = 'SSC.AttributeValueObject'
                'guid' = $Value
            }
        )

        switch ($psboundparameters.keys)
        {
            'AttributeDefinitionId' { $body.attributeDefinitionId = $AttributeDefinitionId }
            'Value'                 { $body.values = $values }
        }

        Add-ObjectDetail -InputObject $body -TypeName PS4SSC.AttributeObject
    }
}
