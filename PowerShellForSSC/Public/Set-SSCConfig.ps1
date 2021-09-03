function Set-SSCConfig
{
    <#
    .SYNOPSIS
        Set PowerShell for SSC module configuration.
    .DESCRIPTION
        Set PowerShell for SSC module configuration, and $PS4SSC module variable.
        This data is used as the default Token and SscUri for most commands.
        If a command takes either a token or a uri, tokens take precedence.
        Credentials can also be stored so that the token can be genereated when needed.
        WARNING: Use this to store the token, uri or credentials on a filesystem at your own risk
    .PARAMETER Token
        Specify a previously generate authentication Token.
    .PARAMETER SscUri
        Specify the API Uri to use, e.g. http://localhost:8080/ssc.
    .PARAMETER TokenType
        The token type to use, one of: 'AnalysisUploadToken', 'CIToken', 'ScanCentralCtrlToken', 'UnifiedLoginToken'
        Recommend type is 'UnifiedLoginToken' for universal API access.
    .PARAMETER Credential
        A previously created Credential object to be used.
    .PARAMETER Proxy
        Proxy to use with Invoke-RESTMethod.
    .PARAMETER ForceToken
        If set to true, an authentication token will be re-generated on every API call.
    .PARAMETER ForceVerbose
        If set to true, we allow verbose output that may include sensitive data
        *** WARNING ***
        If you set this to true, your Software Security Center token will be visible as plain text in verbose output
    .PARAMETER Path
        If specified, save config file to this file path.
        Defaults to PS4SSC.xml in the user temp folder on Windows, or .ps4ssc in the user's home directory on Linux/macOS.
    .EXAMPLE
        # Set the SSC UURI and Force Verbose mode to $true
        Set-SSCConfig -SscUri http://ssc.mydomain.com -TokenType UnifiedLoginToken -ForceVerbose $True
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [cmdletbinding()]
    param(
        [Parameter()]
        [string]$Token,

        [Parameter()]
        [string]$SscUri,

        [Parameter()]
        [ValidateSet('AnalysisUploadToken', 'CIToken', 'ScanCentralCtrlToken', 'UnifiedLoginToken')]
        [string]$TokenType = "CIToken",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [string]$Proxy,

        [Parameter()]
        [bool]$ForceToken,

        [Parameter()]
        [bool]$ForceVerbose,

        [Parameter()]
        [string]$Path = $script:_PS4SSCXmlpath
    )

    switch ($PSBoundParameters.Keys)
    {
        'SscUri'       { $Script:PS4SSC.SscUri = $SscUri }
        'TokenType'    { $Script:PS4SSC.TokenType = $TokenType }
        'Credential'   { $Script:PS4SSC.Credential = $Credential }
        'Token'        { $Script:PS4SSC.Token = $Token }
        'Proxy'        { $Script:PS4SSC.Proxy = $Proxy }
        'ForceToken'   { $Script:PS4SSC.ForceToken = $ForceToken }
        'ForceVerbose' { $Script:PS4SSC.ForceVerbose = $ForceVerbose }
    }

    function encrypt
    {
        param([string]$string)
        if ($String -notlike '' -and (Test-IsWindows)) {
            ConvertTo-SecureString -String $string -AsPlainText -Force
        }
    }

    Write-Verbose "Set-SSCConfig Bound Parameters:  $( $PSBoundParameters | Remove-SensitiveData | Out-String )"

    # Write the global variable and the xml
    $Script:PS4SSC |
        Select-Object -Property Proxy,
        @{ l = 'SscUri'; e = { Encrypt $_.SscUri } },
        @{ l = 'TokenType'; e = { $_.TokenType } },
        @{ l = 'Credential'; e = { $_.Credential } },
        @{ l = 'Token'; e = { Encrypt $_.Token } },
        ForceToken,
        ForceVerbose |
        Export-Clixml -Path $Path -force

}
