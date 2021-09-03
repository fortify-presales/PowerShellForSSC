# using module .\PowerShellForSSC\Class\PowerShellForSSC.Class1.psm1
# Above needs to remain the first line to import Classes
# remove the comment when using classes

# requires -Version 2
# Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

# Dot source the files
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Create / Read config
$script:_PS4SSCXmlpath = Get-SSCConfigPath
if(-not (Test-Path -Path $script:_PS4SSCXmlpath -ErrorAction SilentlyContinue))
{
    Try
    {
        Write-Warning "Did not find config file $($script:_PS4SSCXmlpath), attempting to create"
        [PSCustomObject]@{
            ApiUri = $null
            TokenType = $null
            Credential = $null
            Token = $null
            Proxy = $null
            ForceToken = $False
            ForceVerbose = $False
        } | Export-Clixml -Path $($script:_PS4SSCXmlpath) -Force -ErrorAction Stop
    }
    Catch
    {
        Write-Warning "Failed to create config file $($script:_PS4SSCXmlpath): $_"
    }
}

# Initialize the config variable.
Try
{
    # Import the config
    $PS4SSC = $null
    $PS4SSC = Get-SSCConfig -Source PS4SSC.xml -ErrorAction Stop
}
Catch
{
    Write-Warning "Error importing PS4SSC config: $_"
}

# Create a hashtable for use with the "leaky bucket" rate-limiting algorithm. (Some of SSC's API calls will fail if you request them too quickly.)
# https://en.wikipedia.org/wiki/Leaky_bucket
$Script:APIRateBuckets = @{}

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Export-ModuleMember -Function $Public.Basename
