function Get-SSCApplicationVersionIssues {
    <#
    .SYNOPSIS
        Get SSC Application Version Issues.
    .DESCRIPTION
        Get information about SSC Application Version Issues.
    .PARAMETER Id
        The id of the parent application version.
    .PARAMETER Fields
        A comma separated list of fields to return.
    .PARAMETER Query
        A search-spec of full text search query.
    .PARAMETER OrderBy
        A comma separated list of fields to order by.
    .PARAMETER FilterSet
        Filter set to use.
    .PARAMETER Filter
        Filter to use.
    .PARAMETER GroupId
        Group Id.
    .PARAMETER GroupingType
        Grouping Type.
    .PARAMETER IssueIds
        A comma-separated value list of issue ids. If provided, other filtering and ordering parameters can not be used.
    .PARAMETER ShowHidden
        If 'true', include hidden issues in search results. If 'false', exclude hidden issues from search results. If no options are set, use application version profile settings to get value of this option.
    .PARAMETER ShowRemoved
        If 'true', include removed issues in search results. If 'false', exclude removed issues from search results. If no options are set, use application version profile settings to get value of this option.
    .PARAMETER ShowSuppressed
        If 'true', include suppressed issues in search results. If 'false', exclude suppressed issues from search results. If no options are set, use application version profile settings to get value of this option.
    .PARAMETER ShowShortFilenames
        If 'true', only short file names will be displayed in issues list.
    .PARAMETER Start
        Starting offset for Issues returned.
        Default is 0.
    .PARAMETER Limit
        Limit the number of Issues returned to this number.
        If '-1' or '0' no limit is applied .
        Default is 200.
    .PARAMETER Raw
        If specified, provide raw output and do not parse any responses.
    .PARAMETER Token
        SSC token to use.
        If empty, the value from PS4SSC will be used.
    .PARAMETER Proxy
        Proxy server to use.
        Default value is the value set by Set-SSCConfig
    .EXAMPLE
        # Get any Issues of Application id 1000 that are Critical or High (including Suppressed)
        Get-SSCApplicationVersionIssues -Id 1000 -Query '[fortify priority order]:critical [fortify priority order]:high' -ShowSuppressed
    .EXAMPLE
        # Get any Issues of Application id 100 that are in the Kingdom "Security Features" and are Critical
        Get-SSCApplicationVersionIssues -Id 1000 -Query 'kingdom:"Security Features" [fortify priority order]:critical'
    .LINK
        http://localhost:8080/ssc/html/docs/api-reference/index.jsp#/issue-of-project-version-controller/listIssueOfProjectVersion
    .FUNCTIONALITY
        Fortify Software Security Center
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [int]$Id,
        
        [string]$Fields,
        [string]$Query,
        [string]$OrderBy,
        [switch]$Raw,
        [int]$Start = 0,
        [int]$Limit = 200,
        [string]$FilterSet,
        [string]$Filter,
        [string]$GroupId,
        [string]$GroupingType,
        [string[]]$IssueIds,
        [switch]$ShowHidden,
        [switch]$ShowRemoved,
        [switch]$ShowSuppressed,
        [switch]$ShowShortFilenames,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Token = $Script:PS4SSC.Token,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$SscUri = $Script:PS4SSC.SscUri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Proxy = $Script:PS4SSC.Proxy,

        [switch]$ForceVerbose = $Script:PS4SSC.ForceVerbose
    )
    begin
    {
        $Params = @{}
        if ($Proxy) {
            $Params['Proxy'] = $Proxy
        }
        if ($ForceVerbose) {
            $Params.Add('ForceVerbose', $True)
            $VerbosePreference = "Continue"
        }
        Write-Verbose "Get-SSCScanCentralSASTJobs Bound Parameters: $( $PSBoundParameters | Remove-SensitiveData | Out-String )"
        $Body = @{
            start = $Start
            limit = $Limit
        }
        if ($Fields) {
            $Body.Add("fields", $Fields)
        }
        if ($OrderBy) {
            $Body.Add("orderby", $OrderBy)
        }
        if ($Query) {
            $Body.Add("q", $Query)
            $Body.Add("qm", "issues")
        }
        if ($FilterSet) {
            $Body.Add("filterset", $FilterSet)
        }
        if ($Filter) {
            $Body.Add("filter", $Filter)
        }
        if ($GroupId) {
            $Body.Add("groupid", $GroupId)
        }
        if ($GroupingType) {
            $Body.Add("groupingtype", $GroupingType)
        }
        if ($IssueIds) {
            $Body.Add("ids", $IssueIds -join ",")
        }
        if ($ShowHidden) {
            $Body.Add("showhidden", $True)
        }
        if ($ShowRemoved) {
            $Body.Add("showremoved", $True)
        }
        if ($ShowSuppressed) {
            $Body.Add("showsuppressed", $True)
        }
        if ($ShowShortFilenames) {
            $Body.Add("showshortfilenames", $True)
        }
        $RawIssues = @()
        $TotalCount = 0
    }
    process
    {
        Write-Verbose "Send-SSCApi -Method Get -Operation 'api/v1/projectVersions/$Id/issues'" #$Params
        $Response = Send-SSCApi -Method Get -Operation "/api/v1/projectVersions/$Id/issues" -Body $Body @Params
        $TotalCount = $Response.count
        $RawIssues = $Response.data
        Write-Verbose "Retrieved $TotalCount Issues"
    }
    end {
        if ($Raw) {
            $RawIssues
        } else {
            Parse-SSCIssue -InputObject $RawIssues
        }
    }
}
