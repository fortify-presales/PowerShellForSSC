# Parse artifact
function Parse-SSCArtifact
{
    [cmdletbinding()]
    param($InputObject)

    foreach ($Artifact in $InputObject)
    {
        [PSCustomObject]@{
            PSTypeName = 'SSC.ArtifactObject'
            id = $Artifact.id
            artifactType = $Artifact.artifactType
            status = $Artifact.status
            allowDelete = $Artifact.allowDelete
            allowPurge = $Artifact.allowPurge
            allowApprove = $Artifact.allowApprove
            inModifyingStatus = $Artifact.inModifyingStatus
            uploadDate = $Artifact.uploadDate
            approvalComment = $Artifact.approvalComment
            approvalDate = $Artifact.approvalDate
            approvalUsername = $Artifact.approvalUsername
            auditUpdated = $Artifact.auditUpdated
            messages = $Artifact.messages
            messageCount = $Artifact.messageCount
            purged = $Artifact.purged
            fileName = $Artifact.fileName
            fileSize = $Artifact.fileSize
            fileURL = $Artifact.fileURL
            originalFileName = $Artifact.originalFileName
            uploadIP = $Artifact.uploadIP
            userName = $Artifact.userName
            versionNumber = $Artifact.versionNumber
            otherStatus = $Artifact.otherStatus
            runtimeStatus = $Artifact.runtimeStatus
            scaStatus = $Artifact.scaStatus
            webInspectStatus = $Artifact.webInspectStatus
            lastScanDate = $Artifact.lastScanDate
            scanErrorsCount = $Artifact.scanErrorsCount
            indexed = $Artifact.indexed
            href = $Artifact._href
            Raw = $Artifact
        }
    }
}
