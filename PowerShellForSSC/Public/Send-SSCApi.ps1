function Send-SSCApi {
    <#
    .SYNOPSIS
        Send a request to the SSC REST API.
    .DESCRIPTION
        Send a request to the SSC REST API.
        This function is used by other PS4SSC functions.
        It's a simple wrapper you could use for calls to the SSC API.
    .PARAMETER Method
        REST API Method (Get, Post, Put, Delete ...).
        Defaults to Get.
    .PARAMETER Operation
        SSC API Operation to call, e.g. /api/v1/projects, this will be appended to $SscUri
        Reference: http://localhost:8080/ssc/html/docs/docs.htm
    .PARAMETER Body
        Hash table of arguments to send to the SSC API.
    .PARAMETER BodyFile
        A File containing the Body to be sent to the SSC API.
    .PARAMETER ContentType
        Content Type to send, if not specified defaults to "application/json"
    .PARAMETER Token
        SSC authentication token to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETR SscUri
        SSC API Uri to use, e.g. http://localhost:8080/ssc.
        If empty, the value from PS4SSC will be used.
    .PARAMETER Proxy
        Proxy server to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETER NewToken
        Create a new token using stored credentials.
    .PARAMETER ForceVerbose
        If specified, don't explicitly remove verbose output from Invoke-RestMethod
        *** WARNING ***
        This will expose your data in verbose output.
    .EXAMPLE
        # Get a list of (the first 5) SSC applications
        $Body = @{
            limit = 5
        }
        Send-SSCApi -Operation "/api/v1/projects" -Body $Body -ForceVerbose
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [OutputType([String])]
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Get', 'Post', 'Put', 'Delete', 'Patch')]
        [string]$Method,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Operation,

        [ValidateNotNullOrEmpty()]
        [hashtable]$Body,

        [Parameter(Mandatory=$false)]
        [string]$BodyFile,

        [Parameter(Mandatory=$false)]
        [string]$ContentType = 'application/json',

        [Parameter()]
        [switch]$ToJson,

        [Parameter(Mandatory=$false)]
        [bool]$DataOnly = $False,

        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if (-not $_ -and -not $Script:PS4SSC.Token){
                throw 'Please specify an authentication token or create a new SSC API Token with Get-SSCToken.'
            } else {
                $true
            }
        })]
        [string]$Token = $Script:PS4SSC.Token,

        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if (-not $_ -and -not $Script:PS4SSC.SscUri) {
                throw 'Please supply a SSC API Uri with Set-SSCConfig.'
            } else {
                $true
            }
        })]
        [string]$SscUri = $Script:PS4SSC.SscUri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Proxy = $Script:PS4SSC.Proxy,

        [switch]$ForceToken = $Script:PS4SSC.ForceToken,

        [switch]$ForceVerbose = $Script:PS4SSC.ForceVerbose

    )
    begin
    {
        $Params = @{
            Uri = "$SscUri$Operation"
            ErrorAction = 'Stop'
        }
        if (-not $Method) {
            $Method = 'Get'
        }
        if ($Method -eq 'Get') {
            $Params.Add('Method', 'Get')
            $Params.Add('Body', $Body)
        } elseif ($BodyFile) {
            Write-Verbose "BodyFile is $BodyFile"
            $Params.Add('Method', $Method)
            $Params.Add('InFile', $BodyFile)
            $Params.Add('ContentType', $ContentType)
        } else {
            $Params.Add('Method', $Method)
            $Params.Add('ContentType', $ContentType)
            $Params.add('Body', (ConvertTo-Json $Body))
        }
        if ($Proxy) {
            $Params['Proxy'] = $Proxy
        }
        if ($ForceVerbose) {
            $Params.Add('Verbose', $True)
            $VerbosePreference = "Continue"
        }
        if ($ForceToken) {
            Write-Verbose "Re-creating authentication token"
            Get-SSCToken
            $Token = $Script:PS4SSC.Token
        }
        $Headers = @{ 'Authorization' = "FortifyToken $Token"; 'Accept' = '*/*'; 'Content-Type' = 'application/json'; }

        Write-Verbose "Send-SSCApi Headers: $( $Headers | Remove-SensitiveData | Out-String )"
        Write-Verbose "Send-SSCApi Bound Parameters: $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
    }
    process
    {
        $Response = $null
        try
        {
            if ($Body) {
                Write-Verbose "JSON Payload:"
                Write-Verbose (ConvertTo-Json $Body)
            }
            $Response = Invoke-RestMethod -Headers $Headers @Params
            Write-Verbose "Response:"
            Write-Verbose ($Response | ConvertTo-Json -Depth 10)
        } catch {
            Write-Verbose "Caught Exception:"
            Write-Verbose ($_.Exception | Out-String)
            Write-Error -Exception $_.Exception -Message "$_"
        }
    }
    end
    {
        if ($Response) {
            if ($ToJson) {
                if ($Response.Data -and $DataOnly) {
                    Write-Output $Response.Data | ConvertTo-Json -Depth 10
                } else {
                    Write-Output $Response | ConvertTo-Json -Depth 10
                }
            } else {
                if ($Response.Data -and $DataOnly) {
                    Write-Output $Response.Data
                } else {
                    Write-Output $Response
                }
            }
        } else {
            Write-Verbose "Response is empty."
        }
    }
}
