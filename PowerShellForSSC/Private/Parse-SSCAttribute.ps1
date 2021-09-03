# Parse attribute
function Parse-SSCAttribute
{
    [cmdletbinding()]
    param($InputObject)

    foreach ($Attribute in $InputObject)
    {
        [PSCustomObject]@{
            PSTypeName = 'SSC.AttributeObject'
            attributeDefinitionId = $Attribute.attributeDefinitionId
            value = $Attribute.value
            values = Parse-SSCAttributeValue $Attribute.values
            Raw = $Attribute
        }
    }
}
