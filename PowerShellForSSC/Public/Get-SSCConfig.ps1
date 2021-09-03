Function Get-SSCConfig {
    <#
    .SYNOPSIS
        Get PowerShell For SSC module configuration.
    .DESCRIPTION
        Retrieves the PowerShell for SSC module configuration from the serialized XML file.
    .PARAMETER Source
        Get the config data from either:
            PS4SSC:     the live module variable used for command defaults
            PS4SSC.xml: the serialized PS4SSC.xml that loads when importing the module
        Defaults to PS4SSC.
    .PARAMETER Path
        If specified, read config from this XML file.
        Defaults to PS4SSC.xml in the user temp folder on Windows, or .ps4ssc in the user's home directory on Linux/macOS.
    .EXAMPLE
        # Retrieve the current configuration
        Get-SSCConfig
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [cmdletbinding(DefaultParameterSetName = 'source')]
    param(
        [parameter(ParameterSetName='source')]
        [ValidateSet("PS4SSC","PS4SSC.xml")]
        $Source = "PS4SSC",

        [parameter(ParameterSetName='path')]
        [parameter(ParameterSetName='source')]
        $Path = $script:_PS4SSCXmlpath
    )
    Write-Verbose "Get-SSCConfig Bound Parameters:  $( $PSBoundParameters | Remove-SensitiveData | Out-String )"

    if ($PSCmdlet.ParameterSetName -eq 'source' -and $Source -eq "PS4SSC" -and -not $PSBoundParameters.ContainsKey('Path')) {
        $Script:PS4SSC
    } else {
        function Decrypt {
            param($String)
            if($String -is [System.Security.SecureString]) {
                [System.Runtime.InteropServices.marshal]::PtrToStringAuto(
                        [System.Runtime.InteropServices.marshal]::SecureStringToBSTR(
                                $string))
            }
        }
        Write-Verbose "Retrieving SSC Configuration from $Path"
        Import-Clixml -Path $Path |
                Select-Object -Property Proxy,
                @{l='SscUri';e={Decrypt $_.SscUri}},
                @{l='TokenType';e={$_.TokenType}},
                @{l='Credential';e={$_.Credential}},
                @{l='Token';e={Decrypt $_.Token}},
                ForceToken,
                ForceVerbose
    }

}
