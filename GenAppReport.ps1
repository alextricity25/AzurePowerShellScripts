# Author: Miguel Alex Cantu
# Date: 05/11/2020
# Description:
# This script lists all the applications in our Azure AD tenant

# Loading functions
. ./AzureAuthenticate.ps1
. ./ListAllApplications.ps1
. ./ListAllServicePrincipals.ps1

# Getting access tokens
$accessToken = Get-AccessToken

$reportTemplate = [PSCustomObject][Ordered]@{
    displayName     = $null
}
$azureApplications = List-AllApps($accessToken)
$azureServicePrincipals = List-AllServicePrincipals($accessToken)
$reportedApplications = @()


$testcount = 0
foreach ($app in $azureServicePrincipals.GetEnumerator()) {

    $reportEntry = $reportTemplate.PsObject.Copy()
    $reportEntry.displayName = $app.Value.appDisplayName
    #$reportEntry.createdDateTime = $azureApplications[$app.value.appId].createdDateTime
    $reportEntry | Add-Member -Type NoteProperty -Name "preferredSingleSignOnMode" -Value $app.value.preferredSingleSignOnMode
    $certExpDate = $app.value.keyCredentials[0].endDateTime
    if ($certExpDate) {
        $reportEntry | Add-Member -Type NoteProperty "certExpDate" -Value $certExpDate
    }

    # Get groups and users assigned to service principal
    
    Write-Debug "Getting groups assigned to application $($app.Value.appDisplayName)"
    $appRoleAssignedToURI = "https://graph.microsoft.com/v1.0/servicePrincipals/$($app.Name)/appRoleAssignedTo"
    $appRoleAssignedResponse = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)"} `
                                -Uri $appRoleAssignedToURI `
                                -Method Get
    $groups = @()
    foreach ($group in $appRoleAssignedResponse.value) {
        # Add to groups array only if the service principal is a user or group
        if ($group.principalType -eq "User" -or $group.principalType -eq "Group"){
            $groups += $group.principalDisplayName
        }
    }
    # If the application does not have any users or groups assigned to it, then it's of no concern
    # and we will not include it in the report
    if (!$groups) {
        continue
    }
    $reportEntry | Add-Member -Type NoteProperty "Groups" -Value $($groups -join ", ")

    # Get createdDateTime
    $reportEntry | Add-Member -Type NoteProperty "createdDateTime" -Value "$($azureApplications[$app.value.appId].createdDateTime)"
    
    # Get sign-ins
    $signInsURI = 'https://graph.microsoft.com/v1.0/auditLogs/signIns'
    "Getting Sign Ins for application $($app.value.appId)"
    $appSignIns = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } `
    -Uri  "$($signInsURI)?&`$filter=appId eq `'$($app.value.appId)`'" `
    -Method Get
    if ($appSignIns.value) {
        "$($app.value.appDisplayName): $($appSignIns.value.Count) recent signIns"
        $reportEntry | Add-Member -Type NoteProperty -Name "recentSignIns" -Value $appSignIns.value.Count
    }
    else {
        "$($app.value.appDisplayName): $($appSignIns.value.Count) recent signIns"
        $reportEntry | Add-Member -Type NoteProperty -Name "recentSignIns" -Value '0'
    }
    Start-Sleep -s 1
    #$reportEntry.signInAudience = $app.signInAudience
    #$reportEntry | Add-Member -Type NoteProperty -Name ""
    $reportedApplications += $reportEntry
}

$reportedApplications | Export-Csv -Path C:\Users\mcan2530\Desktop\testapps2.csv -NoTypeInformation