# Parse application
function Parse-SSCApplication
{
    [cmdletbinding()]
    param($InputObject)

    foreach ($Application in $InputObject)
    {
        [PSCustomObject]@{
            PSTypeName = 'SSC.ApplicationObject'
            id = $Application.id
            name = $Application.name
            description = $Application.description
            creationDate = $Application.creationDate
            createdBy = $Application.createdBy
            issueTemplateId = $Application.issueTemplateId
            href = $Application._href
            Raw = $Application
        }
    }
}
