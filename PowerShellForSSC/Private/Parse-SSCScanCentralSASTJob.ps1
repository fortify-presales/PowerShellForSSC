# Parse ScanCentral SAST Job
function Parse-SSCScanCentralSASTJob
{
    [cmdletbinding()]
    param($InputObject)

    foreach ($Job in $InputObject)
    {
        [PSCustomObject]@{
            PSTypeName = 'SSC.SSCScanCentralSASTObject'
            jobCancellable = $Job.jobCancellable
            jobDuration = $Job.jobDuration
            jobExpiryTime = $Job.jobExpiryTime
            jobFinishedTime = $Job.jobFinishedTime
            jobHasFpr = $Job.jobHasFpr
            jobHasLog = $Job.jobHasLog
            jobQueuedTime = $Job.jobQueuedTime
            jobStartedTime = $Job.jobStartedTime
            jobState = $Job.jobState
            jobToken = $Job.jobToken
            projectId = $Job.projectId
            projectName = $Job.projectName
            pvId = $Job.pvId
            pvName = $Job.pvName
            queuedDuration = $Job.queuedDuration
            scaArgs = $Job.scaArgs
            scaBuildId = $Job.scaBuildId
            scaVersion = $Job.scaVersion
            scanDuration = $Job.scanDuration
            submitterEmail = $Job.submitterEmail
            submitterIpAddress = $Job.submitterIpAddress
            submitterUserName = $Job.submitterUserName
            Raw = $Job
        }
    }
}
