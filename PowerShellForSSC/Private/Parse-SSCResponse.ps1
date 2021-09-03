# Parse a standard SSC response
function Parse-SSCResponse
{
    [cmdletbinding()]
    param($InputObject)

    [PSCustomObject]@{
        PSTypeName = 'SSC.ResponseObject'
        count = $InputObject.count
        errorCode = $InputObject.errorCode
        links = $InputObject.links
        message = $InputObject.message
        responseCode = $InputObject.responseCode
        stackTrace = $InputObject.stackTrace
        successCount = $InputObject.successCount
        Raw = $InputObject
    }
}
