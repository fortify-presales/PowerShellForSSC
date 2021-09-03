function Get-SSCConfigPath
{
    [CmdletBinding()]
    param()

    end
    {
        if (Test-IsWindows)
        {
            Join-Path -Path $env:TEMP -ChildPath "$env:USERNAME-$env:COMPUTERNAME-PS4SSC.xml"
        }
        else
        {
            Join-Path -Path $env:HOME -ChildPath '.ps4ssc' # Leading . and no file extension to be Unixy.
        }
    }
}
