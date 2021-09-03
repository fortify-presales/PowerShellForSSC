[![Build status](https://ci.appveyor.com/api/projects/status/egkljq9ok9xhvnhh?svg=true)](https://ci.appveyor.com/project/akevinlee/powershellforssc)

# PowerShell for Fortify Software Security Center (SSC) Module

#### Table of Contents

*   [Overview](#overview)
*   [Current API Support](#current-api-support)
*   [Installation](#installation)
*   [Configuration](#configuration)
*   [Example](#example)
*   [Logging](#logging)
*   [Developing and Contributing](#developing-and-contributing)
*   [Licensing](#licensing)

## Overview

This is a [PowerShell](https://microsoft.com/powershell) [module](https://technet.microsoft.com/en-us/library/dd901839.aspx)
that provides command-line interaction and automation for [Fortify Software Security Center](https://www.microfocus.com/en-us/cyberres/application-security/software-security-center).

----------

## Current API Support

At present, this module can:
 * Authenticate against the SSC API to retrieve and store authentication token
 * Execute a generic SSC API command with authentication
 * Query, add, update and remove Applications and Application Versions

Development is ongoing, with the goal to add broad support for the entire API set.

----------

## Installation

You can get the latest release of the PowerShellForSSC from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PowerShellForSSC)

```PowerShell
Install-Module -Name PowerShellForSSC
```

----------

## Configuration

To access the [Fortify Software Security Center](https://www.microfocus.com/en-us/cyberres/application-security/software-security-center) API you need 
to create an "authentication" token. This module allows the creation and persistence of this token so that it does not 
need to be passed with each command. To create the token, run the following commands to set your API endpoint and request a 
'UnifiedLogin' token:

```PowerShell
Set-SSCConfig -SscUri http://ssc.mydomain.com -TokenType UnifiedLoginToken
Get-SSCToken
```

You will be requested for your login details and the token will then be saved on disk.

## Example

Example command:

```powershell
Get-SSCApplications -FullTextSearch -Query "test" | Out-GridView
```

## Supported Versions

PowerShellForSSC has been tested on PowerShell 5.x (Windows) and PowerShell Core 7.x (Linux).
On Windows it should work on any PowerShell version later than 5.x - however if you find any problems
please raise an [issue](https://github.com/fortify-community-plugins/PowerShellForSSC/issues).
----------

## Developing and Contributing

Please see the [Contribution Guide](CONTRIBUTING.md) for information on how to develop and contribute.

If you have any problems, please consult [GitHub Issues](https://github.com/fortify-community-plugins/PowerShellForSSC/issues)
to see if has already been discussed.

----------

## Licensing

PowerShellForSSC is licensed under the [GNU General Public license](LICENSE).

This is community content provided by and for the benefit of [Micro Focus](https://www.microfocus.com/) customers, 
it is not officially endorsed nor supported via [Micro Focus Software Support](https://www.microfocus.com/en-us/support).


