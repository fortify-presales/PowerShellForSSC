# Parse application version
function Parse-SSCApplicationVersion
{
    [cmdletbinding()]
    param($InputObject)

    foreach ($ApplicationVersion in $InputObject)
    {
        [PSCustomObject]@{
            PSTypeName = 'SSC.ApplicationVersionObject'
            id = $ApplicationVersion.id
            name = $ApplicationVersion.name
            active = $ApplicationVersion.active
            project = Parse-SSCApplication $ApplicationVersion.project
            description = $ApplicationVersion.description
            creationDate = $ApplicationVersion.creationDate
            createdBy = $ApplicationVersion.createdBy
            sourceBasePath = $ApplicationVersion.sourceBasePath
            committed = $ApplicationVersion.committed
            owner = $ApplicationVersion.owner
            securityGroup = $ApplicationVersion.securityGroup
            #currentState = $ApplicationVersion.currentState
            status = $ApplicationVersion.status
            issueTemplateId = $ApplicationVersion.issueTemplateId
            issueTemplateName = $ApplicationVersion.issueTemplateName
            snapshotOutOfDate = $ApplicationVersion.snapshotOutOfDate
            refreshRequired = $ApplicationVersion.refreshRequired
            serverVersion = $ApplicationVersion.serverVersion
            latestScanId = $ApplicationVersion.latestScanId
            mode = $ApplicationVersion.mode
            bugTrackerEnabled = $ApplicationVersion.bugTrackerEnabled
            assignedIssuesCount = $ApplicationVersion.assignedIssuesCount
            attributes = Parse-SSCAttribute $ApplicationVersion.attributes
            href = $ApplicationVersion._href
            Raw = $ApplicationVersion
        }
    }
}
