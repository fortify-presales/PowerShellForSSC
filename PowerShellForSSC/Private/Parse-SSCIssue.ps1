# Parse issue
function Parse-SSCIssue
{
    [cmdletbinding()]
    param($InputObject)

    foreach ($Issue in $InputObject)
    {
        [PSCustomObject]@{
            PSTypeName = 'SSC.IssueObject'
            id = $Issue.id
            projectVersionId = $Issue.projectVersionId
            lastScanId = $Issue.lastScanId
            projectVersionName = $Issue.projectVersionName
            projectName = $Issue.projectName
            revision = $Issue.revision
            folderId = $Issue.folderId
            folderGuid = $Issue.folderGuid
            issueInstanceId = $Issue.issueInstanceId
            issueName = $Issue.issueName
            primaryLocation = $Issue.primaryLocation
            lineNumber = $Issue.lineNumber
            fullFileName = $Issue.fullFileName
            analyzer = $Issue.analyzer
            kingdom = $Issue.kingdom
            priority = $Issue.friority
            reviewed = $Issue.reviewed
            bugURL = $Issue.bugURL
            externalBugId = $Issue.externalBugId
            primaryTag = $Issue.primaryTag
            hasAttachments = $Issue.hasAttachments
            hasCorrelatedIssues = $Issue.hasCorrelatedIssues
            scanStatus = $Issue.scanStatus
            foundDate = $Issue.foundDate
            removedDate = $Issue.removedDate
            engineType = $Issue.engineType
            displayEngineType = $Issue.displayEngineType
            engineCategory = $Issue.engineCategory
            primaryRuleGuid = $Issue.primaryRuleGuid
            impact = $Issue.impact
            likelihood = $Issue.likelihood
            severity = $Issue.severity
            confidence = $Issue.confidence
            audited = $Issue.audited
            issueStatus = $Issue.issueStatus
            primaryTagValueAutoApplied = $Issue.primaryTagValueAutoApplied
            hasComments = $Issue.hasComments
            hidden = $Issue.hidden
            suppressed = $Issue.suppressed
            removed = $Issue.removed
            href = $Issue._href
            Raw = $Issue
        }
    }
}
