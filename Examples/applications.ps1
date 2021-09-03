#
# SSC Application/Version examples
#

$User = "admin"                     # default SSC user
$Password = "admin"                 # default SSC user password
$SSC_URI = "http://localhost:8080"  # default SSC URL
$UserId = 1                         # ids of additional user(s) who will access the application

$AppExists = $False
$AppName = "TestApp"
$AppId = 1
$AppVerName = "1.0"
$PrevAppVer = 1

Import-Module .\PowerShellForSSC\PowerShellForSSC.psm1 -Force

# Initial setup of API endpoint and Token
Set-SSCConfig -SscUri $SSC_URI -TokenType UnifiedLoginToken -ForceVerbose $True
$PWord = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
Get-SSCToken -Credential $Credential

# Check if Application already exists
if (Test-SSCApplication -ApplicationName $AppName) {
    Write-Host "Application $AppName already exists"
    $AppExists = $True
    $AppId = Get-SSCApplicationId -ApplicationName $AppName
}

#
# Create a new Application and Application Version
#

# Create any AttributeObjects first - some might be mandatory
$attributes = @(
    New-SSCAttributeObject -AttributeDefinitionId 5 -Value "New"
    New-SSCAttributeObject -AttributeDefinitionId 6 -Value "Internal"
    New-SSCAttributeObject -AttributeDefinitionId 7 -Value "internalnetwork"
    New-SSCAttributeObject -AttributeDefinitionId 1 -Value "High"
)

# Create the ApplicationVersionObject
if ($AppExists) {
    $appVerObject = New-SSCApplicationVersionObject -ApplicationId $AppId -Name $AppVerName -Description "its description" `
    -IssueTemplateId "Prioritized-HighRisk-Project-Template" -Attributes $attributes #-CopyData -CopyState -CopyVersionId $PrevAppVer
} else {
    $appVerObject = New-SSCApplicationVersionObject -ApplicationName $AppName -Name $AppVerName -Description "its description" `
    -IssueTemplateId "Prioritized-HighRisk-Project-Template" -Attributes $attributes #-CopyData -CopyState -CopyVersionId $PrevAppVer
}
# Add the new Application/Application Version
Write-Host "Creating new application version..."
$appVerResponse = Add-SSCApplicationVersion -ApplicationVersion $appVerObject -ForceVerbose
if ($appVerResponse) {
    $appVerId = $appVerResponse.id
    Write-Host "Created application version with id: $appVerId"
}

Write-Host -NoNewLine 'Press any key to continue...';
[void][System.Console]::ReadKey($FALSE)

#
# Get the new Application Version
#

Write-Host "Getting application version with id: $appVerId"
Get-SSCApplicationVersion -Id $appVerId

Write-Host -NoNewLine 'Press any key to continue...';
[void][System.Console]::ReadKey($FALSE)

#
# Update the Application Version
#

# Create update AttributeObjects first
$updateAttributes = @(
    New-SSCAttributeObject -AttributeDefinitionId 5 -Value "Maintenance"
    New-SSCAttributeObject -AttributeDefinitionId 1 -Value "Medium"
)

# Create the update ApplicationVersionObject
$AppVerName = $AppVerName + ".1"
$appVerUpdateObject = New-SSCApplicationVersionObject -ApplicationName $AppName -Id $appVerId -Name $AppVerName `
    -Description "its updated description" -IssueTemplateId "Prioritized-HighRisk-Project-Template" -Attributes $updateAttributes

# Update the Application Version
Write-Host "Updating application version with id: $appVerId"
Update-SSCApplicationVersion -Id $appVerId -ApplicationVersion $appVerUpdateObject

Write-Host -NoNewLine 'Press any key to continue...';
[void][System.Console]::ReadKey($FALSE)

#
# Delete the Application Version
#

Write-Host "Deleting application version with id: $appVerId"
Remove-SSCApplicationVersion -Id $appVerId

if (Test-SSCApplicationVersion -ApplicationName $AppName -VersionName $AppVerName) {
    Write-Host "Application version no longer exists"
} else {
    throw "Application version still exists!"
}

