function Get-SSCToken
{
    <#
    .SYNOPSIS
        Gets a new SSC authentication token.
    .DESCRIPTION
        Connects to SSC and prints the resultant authentication token and/or saves it in the PowerShell for SSC
        module configuration.
    .PARAMETER SscUri
        SSC Uri to use, e.g. http://localhost:8080/ssc
    .PARAMETER TokenType
        The token type to use, one of: 'AnalysisUploadToken', 'CIToken', 'ScanCentralCtrlToken', 'UnifiedLoginToken'
        Recommend type is 'UnifiedLoginToken' for universal API access.
    .PARAMETER Credential
        The Credential object to be used, if empty you will be prompted for User and Password.
    .PARAMETER Print
        Prints the value of the authentication token to the output.
    .PARAMETER ForceCredential
        If specified and a Credential object has already been stored, this will ignore it and force the
        prompt for a new Credential object.
    .PARAMETER Proxy
        Proxy server to use.
        Optional.
    .PARAMETER ForceVerbose
        If specified, don't explicitly remove verbose output from Invoke-RestMethod
        *** WARNING ***
        This will expose your data in verbose output
    .EXAMPLE
        # Retrieve a 'UnifiedLoginToken' token from 'http://localhost:8080/ssc
        Get-SSCToken -TokenType UnifiedLoginToken -SscUri http://localhost:8080/ssc
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [OutputType([String])]
    [cmdletbinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if (-not$_ -and -not$Script:PS4SSC.SscUri) {
                throw 'Please supply a SSC Api Uri with Set-SSCConfig.'
            } else {
                $true
            }
         })]
        [string]$SscUri = $Script:PS4SSC.SscUri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('AnalysisUploadToken', 'CIToken', 'ScanCentralCtrlToken', 'UnifiedLoginToken')]
        [ValidateScript({
            if (-not$_ -and -not$Script:PS4SSC.TokenType) {
                throw 'Please supply a SSC TokenType with Set-SSCConfig.'
            } else {
                $true
            }
        })]
        [string]$TokenType = $Script:PS4SSC.TokenType,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if (-not$_ -and -not$Script:PS4SSC.Credential) {
                throw 'Please supply a Credential with Set-SSCConfig.'
            } else {
                $true
            }
        })]
        $Credential = $Script:PS4SSC.Credential,

        [switch]$Print = $False,

        [switch]$ForceCredential = $False,

        [string]$Proxy = $Script:PS4SSC.Proxy,
        [switch]$ForceVerbose = $Script:PS4SSC.ForceVerbose
    )

    # Check parameters have values
    if ([string]::IsNullOrEmpty($SscUri)) {
        throw 'Please supply a valid SSC API Uri with Set-SSCConfig.'
    }
    if ([string]::IsNullOrEmpty($TokenType)) {
        throw 'Please supply a valid SSC TokenType with Set-SSCConfig.'
    }
    if ($ForceCredential -or ($Credential -eq $null)) {
        $Credential = Get-Credential
    }

    $Params = @{
        ErrorAction = 'Stop'
    }
    if ($Proxy) {
        $Params['Proxy'] = $Proxy
    }
    if (-not$ForceVerbose) {
        $Params.Add('Verbose', $False)
    }
    if ($ForceVerbose) {
        $Params.Add('Verbose', $true)
    }
    $Params.Add('ContentType', 'application/json')
    Write-Verbose "Get-SSCToken Bound Parameters:  $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
    $Pair = "$($Credential.GetNetworkCredential().UserName):$($Credential.GetNetworkCredential().Password)"
    $EncodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Pair))
    $Headers = @{
        'Authorization' = "Basic $EncodedCreds"
    }
    $Body = @{
        'type' = "$TokenType"
        'description' = "PowerShellForSSC Created Token"
    }
    $Uri = "$SscUri/api/v1/tokens"
    try {
        $Response = $null
        $Response = Invoke-RestMethod -Uri $Uri @Params -Headers $Headers -Method Post -Body (ConvertTo-Json $Body)
    } catch {
        if ($_.ErrorDetails.Message -ne $null) {
            Write-Host $_.ErrorDetails
            # Convert the error-message to an object. (Invoke-RestMethod will not return data by-default if a 4xx/5xx status code is generated.)
            $_.ErrorDetails.Message | ConvertFrom-Json | Parse-SSCError -Exception $_.Exception -ErrorAction Stop
        } else {
            Write-Error -Exception $_.Exception -Message "SSC API call failed: $_"
        }
    }
    # Check to see if we have confirmation that our API call failed.
    # (Responses with exception-generating status codes are handled in the "catch" block above - this one is for errors that don't generate exceptions)
    if ($Response -ne $null -and $Response.ok -eq $False) {
        $Response | Parse-SSCError
    } elseif ($Response) {
        $Token = $Response.data.token
        if ($Print) {
            Write-Host $Token
        }
        Set-SSCConfig -SscUri $SscUri -TokenType $TokenType -Token $Token
    }
    else {
        Write-Verbose "Something went wrong. `$Response is `$null"
    }
}
