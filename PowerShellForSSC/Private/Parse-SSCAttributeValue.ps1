# Parse attribute value
function Parse-SSCAttributeValue
{
    [cmdletbinding()]
    param($InputObject)

    foreach ($AttributeValue in $InputObject)
    {
        [PSCustomObject]@{
            PSTypeName = 'SSC.AttributeValueObject'
            description = $AttributeValue.description
            guid = $AttributeValue.guid
            hidden = $AttributeValue.hidden
            id = $AttributeValue.id
            inUse = $AttributeValue.inUse
            index = $AttributeValue.index
            name = $AttributeValue.name
            objectVersion = $AttributeValue.objectVersion
            projectMetaDataDefId = $AttributeValue.projectMetaDataDefId
            publishVersion = $AttributeValue.publishVersion
            Raw = $AttributeValue
        }
    }
}
